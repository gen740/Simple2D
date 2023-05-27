#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include "Simple2D/Geometry/Rectangle.hh"
#import "Simple2D/objc/Geometry/Base.h"

namespace Simple2D::Geometry {

class Rectangle::pImpl : public pImplBase<Rectangle> {
 public:
  using pImplBase::pImplBase;

  void buildBuffers(NSObject<MTLDevice> * /*device*/) override;
  void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const override;

  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *VertexColorBuffer_{};
  NSObject<MTLBuffer> *IndexBuffer_{};
};

};  // namespace Simple2D::Geometry
