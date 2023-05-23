#import "Simple2D/Simple2D.h"
#import "Simple2D/internal/Renderer.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MyMetalDelegate : NSObject <MTKViewDelegate>
- (MyMetalDelegate *_Nonnull)initWithDevice:(NSObject<MTLDevice> *_Nonnull)pDevice
                              andGeometries:
                                  (std::list<Simple2D::Geometry::Geometry_var> *_Nonnull)geometries;
@property(assign, nonatomic) std::shared_ptr<Renderer> renderer;
@end
