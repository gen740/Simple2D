#include "Simple2D/Simple2D.h"
#include <iostream>

// #define NS_PRIVATE_IMPLEMENTATION
// #define MTL_PRIVATE_IMPLEMENTATION
// #define MTK_PRIVATE_IMPLEMENTATION
// #define CA_PRIVATE_IMPLEMENTATION
#include <simd/simd.h>

#include <AppKit/AppKit.h>
#include <Cocoa/Cocoa.h>
#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(strong, nonatomic) NSWindow *window;
@property(assign, nonatomic) id<MTLDevice> device;
@property(strong, nonatomic) MTKView *metal_view;
@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)n {
  std::cout << "applicationWillFinishLaunching Start" << std::endl;

  // NS::Menu *pMenu = createMenuBar();
  // auto *pApp = reinterpret_cast<NS::Application *>(pNotification->object());
  // pApp->setMainMenu(pMenu);
  // pApp->setActivationPolicy(NS::ActivationPolicy::ActivationPolicyRegular);
  std::cout << "applicationWillFinishLaunching End" << std::endl;
}

- (void)applicationDidFinishLaunching:(NSNotification *)n {
  std::cout << "applicationDidFinishLaunching Start" << std::endl;

  auto frame = NSMakeRect(100, 100, 512, 512);
  self.window = [[NSWindow alloc] initWithContentRect:frame
                                            styleMask:NSWindowStyleMaskBorderless
                                              backing:NSBackingStoreBuffered
                                                defer:NO];
  // [self.window center];
  // Create the MTLDevice and the MetalView
  self.device = MTLCreateSystemDefaultDevice();
  self.metal_view = [[MTKView alloc] initWithFrame:frame device:self.device];
  [self.metal_view setColorPixelFormat:MTLPixelFormatBGRA8Unorm_sRGB];
  [self.metal_view setClearColor:MTLClearColorMake(1.0, 0.0, 0.0, 1.0)];

  [self.window setContentView:self.metal_view];
  [self.window setTitle:@"00-Window"];
  [self.window makeKeyAndOrderFront:nil];
  std::cout << "applicationDidFinishLaunching End" << std::endl;
}
@end

class Simple2D::App::Impl {
 public:
  Impl() {
    // this->Window_ = [[NSWindow alloc] init];
    this->delegate_ = [[AppDelegate alloc] init];
    // this->notification_ = [[NSNotification alloc] init];
  }

  void run() {
    std::cout << "Run" << std::endl;
    auto *app = [NSApplication sharedApplication];
    [app setDelegate:this->delegate_];
    [app run];
  }

 private:
  // NSWindow *Window_{};
  // MTKView *MtkView_{};
  // NSApplication *app_{};
  // NSNotification *notification_{};
  AppDelegate *delegate_{};
};

Simple2D::App::App() : pimpl(std::make_shared<Simple2D::App::Impl>()) {
  // std::cout << "Foo" << std::endl;
}

void Simple2D::App::run() { pimpl->run(); }
