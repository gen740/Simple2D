#include <AppKit/AppKit.h>
#import <Simple2D/objc/AppDelegate.h>
#import <Simple2D/objc/MetalDelegate.h>
#import <Simple2D/objc/Window.h>

#import <CoreImage/CoreImage.h>

@implementation AppDelegate
- (AppDelegate *)initWithGeometries:(std::list<Simple2D::Geometry::Geometry_var> *)geometries {
  self.geometries_ = geometries;
  return self;
}

- (NSMenu *)createMenuBar_ {  // 1322
  auto *MainMenu = [[NSMenu alloc] init];

  auto *AppMenuItem = [[NSMenuItem alloc] init];
  auto *AppMenu = [[NSMenu alloc] initWithTitle:@"AppName"];
  AppMenuItem.submenu = AppMenu;

  auto *WindowMenuItem = [[NSMenuItem alloc] init];
  auto *WindowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
  WindowMenuItem.submenu = WindowMenu;

  // Application Quit
  auto *AppQuitItem = [AppMenu addItemWithTitle:@"Quit app"
                                         action:@selector(appQuit:)
                                  keyEquivalent:@"q"];
  AppQuitItem.target = self;
  AppQuitItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;

  // Window Close
  auto *CloseWindowItem = [WindowMenu addItemWithTitle:@"Close Window"
                                                action:@selector(windowClose:)
                                         keyEquivalent:@"w"];
  CloseWindowItem.target = self;
  CloseWindowItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;

  // Save Image
  auto *SaveImageItem = [WindowMenu addItemWithTitle:@"Save as png"
                                              action:@selector(saveAction:)
                                       keyEquivalent:@"s"];
  SaveImageItem.target = self;
  SaveImageItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;

  [MainMenu addItem:AppMenuItem];
  [MainMenu addItem:WindowMenuItem];

  return MainMenu;
}

- (void)applicationWillFinishLaunching:(NSNotification *)pNotification {
  NSApplication *pApp = pNotification.object;
  pApp.menu = self.createMenuBar_;
  [pApp setActivationPolicy:NSApplicationActivationPolicyRegular];
}

- (void)applicationDidFinishLaunching:(NSNotification *)pNotification {
  self.window_ = [[Simple2DWindow alloc] initWithContentRect:NSMakeRect(100, 100, 512, 512)];
  [self.window_ center];
  self.device_ = MTLCreateSystemDefaultDevice();
  self.metalView_ = [[MTKView alloc] initWithFrame:NSMakeRect(100, 100, 512, 512)
                                            device:self.device_];
  (self.metalView_).colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
  (self.metalView_).clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);

  self.metalDelegate_ = [[MyMetalDelegate alloc] initWithDevice:self.device_
                                                  andGeometries:self.geometries_
                                                        andView:self.metalView_];
  (self.metalView_).delegate = self.metalDelegate_;

  (self.window_).contentView = self.metalView_;
  (self.window_).title = @"00 - Window";
  [self.window_ makeKeyAndOrderFront:nil];
  // auto callback = [=](NSEvent *_Nonnull event) {};
  // [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:callback];

  NSApplication *pApp = pNotification.object;
  [pApp activateIgnoringOtherApps:TRUE];
}

- (void)appQuit:(id)sender {
  [[NSApplication sharedApplication] terminate:sender];
}
- (void)windowClose:(id)sender {
  [[NSApplication sharedApplication].windows.firstObject close];
}

- (void)saveAction:(id)seder {
  self.inputWindow_ = [[Simple2DWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 120)];

  self.textField_ = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 50, 260, 24)];
  [self.inputWindow_.contentView addSubview:self.textField_];

  auto *inputDialog = [[NSText alloc] initWithFrame:NSMakeRect(20, 80, 260, 20)];
  [inputDialog setString:@"Input the filename"];
  [inputDialog setDrawsBackground:NO];
  [inputDialog setEditable:NO];
  [inputDialog setSelectable:NO];
  [self.inputWindow_.contentView addSubview:inputDialog];

  auto *okButton = [[NSButton alloc] initWithFrame:NSMakeRect(160, 20, 120, 20)];
  okButton.bordered = NO;
  okButton.title = @"Save as png";
  okButton.buttonType = NSButtonTypeMomentaryLight;
  okButton.bezelStyle = NSBezelStyleRoundRect;
  okButton.target = self;
  // okButton.contentTintColor = [NSColor MTLCreateSystemDefaultDeice];
  okButton.wantsLayer = TRUE;
  okButton.layer.backgroundColor = [NSColor systemBlueColor].CGColor;
  okButton.action = @selector(saveImage);
  [self.inputWindow_.contentView addSubview:okButton];

  auto *cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(20, 20, 120, 20)];
  cancelButton.bordered = YES;
  cancelButton.title = @"Cancel";
  cancelButton.buttonType = NSButtonTypeMomentaryLight;
  cancelButton.bezelStyle = NSBezelStyleRoundRect;
  cancelButton.target = self;
  cancelButton.action = @selector(closeInputWindow);
  [self.inputWindow_.contentView addSubview:cancelButton];

  [self.inputWindow_ center];
  [self.inputWindow_ makeKeyAndOrderFront:nil];
}
- (void)saveImage {
  std::cout << self.textField_.stringValue.UTF8String << std::endl;
  [self.inputWindow_ close];
}

- (void)closeInputWindow {
  [self.inputWindow_ close];
}
@end
