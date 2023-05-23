#import <Simple2D/objc/AppDelegate.h>
#import <Simple2D/objc/MetalDelegate.h>

@implementation MenuController : NSObject
- (void)appQuit:(id)sender {
  [[NSApplication sharedApplication] stop:sender];
}
- (void)windowClose:(id)sender {
  [[NSApplication sharedApplication].windows.firstObject close];
}
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
                                        handler:[=](NSEvent *_Nonnull event) {
                                          NSString *characters = [event characters];
                                          if ([characters length] != 0U) {
                                            unichar character = [characters characterAtIndex:0];
                                            if (character == 'q') {
                                              [NSApp stop:self];
                                            }
                                          }
                                          return event;
                                        }];

  NSApplication *pApp = pNotification.object;
  [pApp activateIgnoringOtherApps:TRUE];
}
@end
