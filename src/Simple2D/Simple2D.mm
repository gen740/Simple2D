#include "Simple2D/Simple2D.h"
#include <Foundation/Foundation.h>
#include <iostream>
#include <semaphore>

#include "Simple2D/internal/shader.h"

#include "Simple2D/Geometry/Triangle.h"
#include "Simple2D/Geometry/internal/TrianglePimpl.h"

#define NS_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#define MTK_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#include <simd/simd.h>

#include <AppKit/AppKit.h>
#include <Cocoa/Cocoa.h>
#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>

#if !__has_feature(objc_arc)
#error "ARC is off"
#endif

namespace shader_types {
struct InstanceData {
  simd::float4x4 instanceTransform;
  simd::float4 instanceColor{};
};
}  // namespace shader_types

@interface MenuController : NSObject
- (void)appQuit:(id)sender;
- (void)windowClose:(id)sender;
@end

@implementation MenuController : NSObject
- (void)appQuit:(id)sender {
  // [[NSApplication sharedApplication] terminate:sender];
  [[NSApplication sharedApplication] stop:sender];
}
- (void)windowClose:(id)sender {
  [[NSApplication sharedApplication].windows.firstObject close];
}
@end

class Renderer {
 public:
  explicit Renderer(NSObject<MTLDevice> *pDevice,
                    std::list<Simple2D::Geometry::Geometry_var> *geometries)
      : geometries(geometries) {
    _pDevice = pDevice;
    _pCommandQueue = [pDevice newCommandQueue];
    buildShaders();
    buildBuffers();
  }
  ~Renderer() = default;

  void buildShaders() {
    NSError *pError;

    auto *pLibrary =
        [_pDevice newLibraryWithSource:[NSString stringWithUTF8String:Simple2D::Shader::ShaderSrc]
                               options:nullptr
                                 error:&pError];
    if (pLibrary == nullptr) {
      std::cout << pError.localizedDescription.UTF8String << std::endl;
      assert(false);
    }

    auto pVertexFn = [pLibrary newFunctionWithName:@"vertexMain"];
    auto pFragFn = [pLibrary newFunctionWithName:@"fragmentMain"];
    auto *pDesc = [[MTLRenderPipelineDescriptor alloc] init];
    [pDesc setVertexFunction:pVertexFn];
    [pDesc setFragmentFunction:pFragFn];
    pDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;

    _pPSO = [_pDevice newRenderPipelineStateWithDescriptor:pDesc error:&pError];
    if (_pPSO == nullptr) {
      std::cout << pError.localizedDescription.UTF8String << std::endl;
      assert(false);
    }
    _pShaderLibrary = pLibrary;
  }

  void buildBuffers() {
    for (auto &a : *geometries) {
      std::visit([=](auto &x) { x->pimpl_->buildBuffers(_pDevice); }, a);
    }
  }

  void draw(MTKView *pView) {
    @autoreleasepool {
      auto *pCmd = [_pCommandQueue commandBuffer];
      // _semaphore.acquire();
      // [pCmd addCompletedHandler:[=](id<MTLCommandBuffer>) { this->_semaphore.release(1); }];

      auto *pRpd = pView.currentRenderPassDescriptor;
      auto *pEnc = [pCmd renderCommandEncoderWithDescriptor:pRpd];

      [pEnc setRenderPipelineState:_pPSO];
      for (auto &a : *geometries) {
        std::visit([&](auto &x) { x->pimpl_->draw(pEnc); }, a);
      }
      [pEnc endEncoding];
      [pCmd presentDrawable:pView.currentDrawable];
      [pCmd commit];
    }
  }

  void addGeometry(const Simple2D::Geometry::Geometry_var &geometry) {
    geometries->push_back(geometry);
  }

 private:
  NSObject<MTLDevice> *_pDevice;
  NSObject<MTLCommandQueue> *_pCommandQueue;
  NSObject<MTLLibrary> *_pShaderLibrary;
  NSObject<MTLRenderPipelineState> *_pPSO{};
  std::list<Simple2D::Geometry::Geometry_var> *geometries;
  static constexpr int kMaxFramesInFlight = 3;
  std::array<NSObject<MTLBuffer> *, kMaxFramesInFlight> _pInstanceDataBuffer{};
  std::counting_semaphore<kMaxFramesInFlight> _semaphore{3};
};

@class AppDelegate;

@interface MyMetalDelegate : NSObject <MTKViewDelegate>
@property(assign, nonatomic) std::shared_ptr<Renderer> renderer;
@end

@implementation MyMetalDelegate
- (MyMetalDelegate *)initWithDevice:(NSObject<MTLDevice> *)pDevice
                      andGeometries:(std::list<Simple2D::Geometry::Geometry_var> *)geometries {
  self.renderer = std::make_shared<Renderer>(pDevice, geometries);
  return self;
}
- (void)drawInMTKView:(MTKView *)view {
  self.renderer->draw(view);
}
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(strong, nonatomic) NSWindow *window;
@property(strong, nonatomic) id<MTLDevice> device;
@property(strong, nonatomic) MTKView *metal_view;
@property(strong, nonatomic) MyMetalDelegate *metal_delegate;
@property(strong, nonatomic) MenuController *controller;
@property(assign, nonatomic) std::list<Simple2D::Geometry::Geometry_var> *geometries;
@property(NS_NONATOMIC_IOSONLY, readonly, copy) NSMenu *createMenuBar;
@end

@implementation AppDelegate
- (AppDelegate *)initWithGeometries:(std::list<Simple2D::Geometry::Geometry_var> *)geometries {
  self.geometries = geometries;
  return self;
}

- (NSMenu *)createMenuBar {  // 1322
  auto *pMainMenu = [[NSMenu alloc] init];
  auto *pAppMenuItem = [[NSMenuItem alloc] init];
  auto *pAppMenu = [[NSMenu alloc] initWithTitle:@"Appname"];

  self.controller = [[MenuController alloc] init];
  auto *pAppQuitItem = [pAppMenu addItemWithTitle:@"Quit app"
                                           action:@selector(appQuit:)
                                    keyEquivalent:@"q"];
  pAppQuitItem.target = self.controller;

  pAppQuitItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;
  pAppMenuItem.submenu = pAppMenu;

  auto *pWindowMenuItem = [[NSMenuItem alloc] init];
  auto *pWindowMenu = [[NSMenu alloc] initWithTitle:@"Window"];

  auto *pCloseWindowItem = [pWindowMenu addItemWithTitle:@"Close Window"
                                                  action:@selector(windowClose:)
                                           keyEquivalent:@"w"];
  pCloseWindowItem.target = self.controller;
  pCloseWindowItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;
  pWindowMenuItem.submenu = pWindowMenu;

  [pMainMenu addItem:pAppMenuItem];
  [pMainMenu addItem:pWindowMenuItem];

  return pMainMenu;
}

- (void)applicationWillFinishLaunching:(NSNotification *)pNotification {
  NSApplication *pApp = pNotification.object;
  pApp.menu = self.createMenuBar;
  [pApp setActivationPolicy:NSApplicationActivationPolicyRegular];
}

- (void)applicationDidFinishLaunching:(NSNotification *)pNotification {
  self.window =
      [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 512, 512)
                                  styleMask:NSWindowStyleMaskClosable | NSWindowStyleMaskTitled
                                    backing:NSBackingStoreBuffered
                                      defer:NO];
  [self.window center];
  self.device = MTLCreateSystemDefaultDevice();
  self.metal_view = [[MTKView alloc] initWithFrame:NSMakeRect(100, 100, 512, 512)
                                            device:self.device];
  (self.metal_view).colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
  (self.metal_view).clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0);

  self.metal_delegate = [[MyMetalDelegate alloc] initWithDevice:self.device
                                                  andGeometries:self.geometries];
  (self.metal_view).delegate = self.metal_delegate;

  (self.window).contentView = self.metal_view;
  (self.window).title = @"00 - Window";
  [self.window makeKeyAndOrderFront:nil];

  [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                        handler:^NSEvent *_Nullable(NSEvent *_Nonnull event) {
                                          NSString *characters = [event characters];
                                          if ([characters length] != 0U) {
                                            // unichar character = [characters characterAtIndex:0];
                                            std::cout << [characters UTF8String] << std::endl;
                                            // if (character == 'q') {
                                            //   [NSApp terminate:self];
                                            // }
                                          }
                                          return event;
                                        }];

  NSApplication *pApp = pNotification.object;
  [pApp activateIgnoringOtherApps:TRUE];
}
@end

struct Simple2D::App::Impl {
 public:
  explicit Impl(std::list<Simple2D::Geometry::Geometry_var> *geometries) : geometries(geometries) {
    this->delegate_ = [[AppDelegate alloc] initWithGeometries:geometries];
  }

  void run() {
    @autoreleasepool {
      this->pApp_ = [NSApplication sharedApplication];
      pApp_.delegate = this->delegate_;
      [pApp_ run];
    }
  }
  ~Impl() = default;

  AppDelegate *delegate_;
  NSApplication *pApp_;
  std::list<Simple2D::Geometry::Geometry_var> *geometries;
};

Simple2D::App::App() : pimpl(std::make_shared<Simple2D::App::Impl>(&this->geometries)) {}
Simple2D::App::~App() = default;

void Simple2D::App::run() { pimpl->run(); }

void Simple2D::App::addGeometry(const Geometry::Geometry_var &geometry) {
  geometries.push_back(geometry);
  // this->pimpl->delegate_.metal_delegate.renderer->addGeometry(geometry);
}

// template <class T>
// std::shared_ptr<T> Simple2D::App::addGeometry() {
//   auto geometry = std::make_shared<T>();
//   this->pimpl->delegate_.metal_delegate.renderer->addGeometry(geometry);
//   return geometry;
// }
//
// template std::shared_ptr<Simple2D::Geometry::Triangle> Simple2D::App::addGeometry();
