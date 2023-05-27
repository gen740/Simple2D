#import <Simple2D/objc/Window.h>

@implementation Simple2DWindow
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {

  self = [super initWithContentRect:contentRect
                          styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                              defer:NO];
  if (self != nil) {
    // Start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    // Turn off opacity so that the parts of the window that are not drawn into are transparent.
    [self setOpaque:NO];
  }
  return self;
}
@end
