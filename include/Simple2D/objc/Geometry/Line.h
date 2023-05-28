#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include <vector>

#include "Simple2D/Geometry/Line.hh"
#import "Simple2D/objc/Geometry/Base.h"

namespace Simple2D::Geometry {

class Line::pImpl : public pImplBase<Line> {
 public:
  using pImplBase::pImplBase;

  void buildBuffers(NSObject<MTLDevice> * /*device*/) override;
  void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const override;

  // std::vector<float3> vertexes_{};

  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *VertexColorBuffer_{};
  NSObject<MTLBuffer> *IndexBuffer_{};
};

};  // namespace Simple2D::Geometry
