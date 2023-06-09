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
  @autoreleasepool {
    auto *AppMenuItem = [[NSMenuItem alloc] init].autorelease;
    auto *AppMenu = [[NSMenu alloc] initWithTitle:@"AppName"].autorelease;
    AppMenuItem.submenu = AppMenu;

    auto *WindowMenuItem = [[NSMenuItem alloc] init].autorelease;
    auto *WindowMenu = [[NSMenu alloc] initWithTitle:@"Window"].autorelease;
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
  }
  return MainMenu;
}

- (void)applicationWillFinishLaunching:(NSNotification *)pNotification {
  NSApplication *pApp = pNotification.object;
  pApp.menu = self.createMenuBar_;
  pApp.activationPolicy = NSApplicationActivationPolicyRegular;
}

- (void)applicationDidFinishLaunching:(NSNotification *)pNotification {
  self.window_ = [[Simple2DWindow alloc] initWithContentRect:NSMakeRect(100, 100, 512, 512)
                                               withFixedSize:YES];
  [self.window_ center];

  self.device_ = MTLCreateSystemDefaultDevice();
  self.metalView_ = [[MTKView alloc] initWithFrame:NSMakeRect(100, 100, 512, 512)
                                            device:self.device_];
  self.metalView_.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
  self.metalView_.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
  self.metalView_.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
  self.metalView_.sampleCount = 4;

  self.metalDelegate_ = [[MyMetalDelegate alloc] initWithDevice:self.device_
                                                  andGeometries:self.geometries_
                                                        andView:self.metalView_];
  (self.metalView_).delegate = self.metalDelegate_;

  (self.window_).contentView = self.metalView_;
  (self.window_).title = @"00 - Window";
  [self.window_ makeKeyAndOrderFront:nil];

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
  @autoreleasepool {
    self.metalDelegate_.renderer->pauseDraw();
    self.inputWindow_ = [[Simple2DWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 180)];

    // NSOpenPanel *panel = [NSOpenPanel openPanel];
    // [panel setCanChooseDirectories:YES];
    // [panel setCanChooseFiles:NO];
    //
    // if ([panel runModal] == NSModalResponseOK) {
    //   NSURL *url = [[panel URLs] objectAtIndex:0];
    //   NSLog(@"Directory path: %@", [url path]);
    // }

    // [NSAlert a]
    self.textField_ = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 50, 260, 24)];
    self.textField_.bordered = NO;

    [self.inputWindow_.contentView addSubview:self.textField_];

    auto *inputDialog = [[NSText alloc] initWithFrame:NSMakeRect(20, 120, 260, 20)].autorelease;
    inputDialog.string = @"Input the filename";
    inputDialog.drawsBackground = NO;
    inputDialog.editable = NO;
    inputDialog.editable = NO;
    inputDialog.selectable = NO;
    [self.inputWindow_.contentView addSubview:inputDialog];

    auto *okButton = [[NSButton alloc] initWithFrame:NSMakeRect(160, 20, 120, 20)].autorelease;
    okButton.action = @selector(saveImage);
    okButton.bordered = NO;
    okButton.title = @"Save as png";
    okButton.buttonType = NSButtonTypeMomentaryLight;
    okButton.bezelStyle = NSBezelStyleRoundRect;
    okButton.target = self;
    // okButton.contentTintColor = [NSColor MTLCreateSystemDefaultDeice];
    okButton.wantsLayer = TRUE;
    okButton.layer.backgroundColor = [NSColor systemBlueColor].CGColor;
    okButton.layer.cornerRadius = 10.0;
    // okButton.layer.
    [self.inputWindow_.contentView addSubview:okButton];

    auto *cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(20, 20, 120, 20)].autorelease;
    cancelButton.action = @selector(closeInputWindow);
    cancelButton.bordered = NO;
    cancelButton.title = @"Cancel";
    cancelButton.buttonType = NSButtonTypeMomentaryLight;
    cancelButton.bezelStyle = NSBezelStyleRoundRect;
    cancelButton.target = self;
    cancelButton.wantsLayer = YES;
    cancelButton.layer.backgroundColor = [NSColor systemRedColor].CGColor;
    cancelButton.layer.cornerRadius = 10.0;
    [self.inputWindow_.contentView addSubview:cancelButton];

    auto *directoryField =
        [[NSTextField alloc] initWithFrame:NSMakeRect(20, 100, 140, 20)].autorelease;
    directoryField.stringValue = @"/Users/fujimotogen/Downloads";
    directoryField.bordered = NO;
    directoryField.editable = NO;
    directoryField.selectable = NO;
    directoryField.alignment = NSTextAlignmentCenter;
    directoryField.wantsLayer = YES;
    directoryField.backgroundColor = NSColor.cyanColor;
    directoryField.textColor = NSColor.blackColor;
    directoryField.layer.cornerRadius = 10.0;
    directoryField.layer.borderWidth = 0.0;

    [self.inputWindow_.contentView addSubview:directoryField];

    auto *selectDirectoryButton =
        [[NSButton alloc] initWithFrame:NSMakeRect(120, 120, 40, 20)].autorelease;
    selectDirectoryButton.bordered = NO;
    selectDirectoryButton.image =
        [[NSImage alloc]
            initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icons/folder@2x"
                                                                   ofType:@"png"]]
            .autorelease;
    selectDirectoryButton.buttonType = NSButtonTypeMomentaryLight;
    selectDirectoryButton.bezelStyle = NSBezelStyleRoundRect;
    selectDirectoryButton.target = self;
    selectDirectoryButton.wantsLayer = TRUE;
    selectDirectoryButton.layer.backgroundColor = [NSColor systemCyanColor].CGColor;
    selectDirectoryButton.layer.cornerRadius = 10.0;

    [self.inputWindow_.contentView addSubview:selectDirectoryButton];

    [self.inputWindow_ center];
    [self.inputWindow_ makeKeyAndOrderFront:nil];

    self.metalDelegate_.renderer->resumeDraw();
  }
}

- (void)saveImage {
  std::cout << self.textField_.stringValue.UTF8String << std::endl;
  // self.metalDelegate_.renderer.
  [self.inputWindow_ close];
}

- (void)closeInputWindow {
  [self.inputWindow_ close];
}
@end
