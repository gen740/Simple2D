#import <AppKit/AppKit.h>
#include <objc/objc.h>

@interface Simple2DWindow : NSWindow
- (id)initWithContentRect:(NSRect)contentRect;
- (id)initWithContentRect:(NSRect)contentRect withFixedSize:(BOOL)fixedsize;
@end
