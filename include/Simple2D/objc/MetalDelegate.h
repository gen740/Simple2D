#import "Simple2D/Simple2D.hh"
#import "Simple2D/objc/Renderer.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MyMetalDelegate : NSObject <MTKViewDelegate>
- (MyMetalDelegate *_Nonnull)initWithDevice:(NSObject<MTLDevice> *_Nonnull)pDevice
                              andGeometries:
                                  (std::list<Simple2D::Geometry::Geometry_var> *_Nonnull)geometries
                                    andView:(MTKView *_Nonnull)view;
@property(assign, nonatomic) std::shared_ptr<Renderer> renderer;
@property(strong, nonatomic) MTKView *_Nonnull view_;
@end
