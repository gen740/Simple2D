#import <Simple2D/objc/Window.h>
#include <iostream>
#include <stdexcept>

@implementation Simple2DWindow
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
  std::cerr << "This Constructer is duprecated " << __PRETTY_FUNCTION__ << std::endl;
  throw std::runtime_error("Duprecated constructor");
  return self;
}
- (id)initWithContentRect:(NSRect)contentRect withFixedSize:(BOOL)fixedsize {
  NSWindowStyleMask styleMask = NSWindowStyleMaskTitled;
  styleMask |= NSWindowStyleMaskFullSizeContentView;  //
  styleMask |= NSWindowStyleMaskClosable;             //
  styleMask |= NSWindowStyleMaskMiniaturizable;       //
  if (fixedsize == 0) {
    styleMask |= NSWindowStyleMaskResizable;
  }
  self = [super initWithContentRect:contentRect
                          styleMask:styleMask
                            backing:NSBackingStoreBuffered
                              defer:NO];
  self.titlebarAppearsTransparent = YES;
  self.titleVisibility = NSWindowTitleHidden;
  self.showsToolbarButton = YES;
  return self;
}

- (id)initWithContentRect:(NSRect)contentRect {
  return [self initWithContentRect:contentRect withFixedSize:NO];
}

@end
