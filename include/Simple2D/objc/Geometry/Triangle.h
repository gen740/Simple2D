#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include "Simple2D/Geometry/Triangle.hh"
#import "Simple2D/objc/Geometry/Base.h"

namespace Simple2D::Geometry {

class Triangle::pImpl : public pImplBase<Triangle> {
 public:
  using pImplBase::pImplBase;
  ~pImpl();

  void buildBuffers(NSObject<MTLDevice> * /*device*/) override;
  void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const override;

  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *VertexColorBuffer_{};
};

}  // namespace Simple2D::Geometry
