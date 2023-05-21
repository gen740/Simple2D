#include "Simple2D/Simple2D.h"
#include <iostream>

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
  explicit Renderer(NSObject<MTLDevice> *pDevice) {
    _pDevice = pDevice;
    _pCommandQueue = [pDevice newCommandQueue];
  }
  ~Renderer() = default;

  void draw(MTKView *pView) {
    @autoreleasepool {
      auto *pCmd = [_pCommandQueue commandBuffer];
      auto *pRpd = pView.currentRenderPassDescriptor;
      auto *pEnc = [pCmd renderCommandEncoderWithDescriptor:pRpd];
      [pEnc endEncoding];
      [pCmd presentDrawable:pView.currentDrawable];
      [pCmd commit];

    }
  }

 private:
  NSObject<MTLDevice> *_pDevice;
  NSObject<MTLCommandQueue> *_pCommandQueue;
};

@interface MyMetalDelegate : NSObject <MTKViewDelegate>
@property(assign, nonatomic) std::shared_ptr<Renderer> renderer;
@end

@implementation MyMetalDelegate
- (MyMetalDelegate *)initWithDevice:(NSObject<MTLDevice> *)pDevice {
  self.renderer = std::make_shared<Renderer>(pDevice);
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
@property(NS_NONATOMIC_IOSONLY, readonly, copy) NSMenu *createMenuBar;
@end

@implementation AppDelegate

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

  self.metal_delegate = [[MyMetalDelegate alloc] initWithDevice:self.device];
  (self.metal_view).delegate = self.metal_delegate;

  (self.window).contentView = self.metal_view;
  (self.window).title = @"00 - Window";
  [self.window makeKeyAndOrderFront:nil];

  NSApplication *pApp = pNotification.object;
  [pApp activateIgnoringOtherApps:TRUE];
}
@end

struct Simple2D::App::Impl {
 public:
  Impl() { this->delegate_ = [[AppDelegate alloc] init]; }

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
};

Simple2D::App::App() : pimpl(std::make_shared<Simple2D::App::Impl>()) {}
Simple2D::App::~App() = default;

void Simple2D::App::run() { pimpl->run(); }
