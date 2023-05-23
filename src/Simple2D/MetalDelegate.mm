#import "Simple2D/objc/MetalDelegate.h"

@implementation MyMetalDelegate
- (MyMetalDelegate *_Nonnull)initWithDevice:(NSObject<MTLDevice> *_Nonnull)pDevice
                              andGeometries:(std::list<Simple2D::Geometry::Geometry_var> *_Nonnull)
                                                geometries {
  self.renderer = std::make_shared<Renderer>(pDevice, geometries);
  return self;
}
- (void)drawInMTKView:(MTKView *_Nonnull)view {
  self.renderer->draw(view);
}
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

@end
