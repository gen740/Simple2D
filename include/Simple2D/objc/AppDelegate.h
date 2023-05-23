#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Simple2D/Simple2D.hpp>
#import <Simple2D/objc/MetalDelegate.h>

@interface MenuController : NSObject
- (void)appQuit:(id)sender;
- (void)windowClose:(id)sender;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(strong, nonatomic) NSWindow *window;
@property(strong, nonatomic) id<MTLDevice> device;
@property(strong, nonatomic) MTKView *metal_view;
@property(strong, nonatomic) MyMetalDelegate *metal_delegate;
@property(strong, nonatomic) MenuController *controller;
@property(assign, nonatomic) std::list<Simple2D::Geometry::Geometry_var> *geometries;
@property(NS_NONATOMIC_IOSONLY, readonly, copy) NSMenu *createMenuBar;
- (AppDelegate *)initWithGeometries:(std::list<Simple2D::Geometry::Geometry_var> *)geometries;
@end
