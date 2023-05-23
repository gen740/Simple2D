#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include <Simple2D/Geometry/Rectangle.hpp>

class Simple2D::Geometry::Rectangle::pImpl {
 public:
  pImpl() = delete;

  pImpl(const pImpl &) = delete;
  pImpl(pImpl &&) = delete;
  pImpl &operator=(const pImpl &) = delete;
  pImpl &operator=(pImpl &&) = delete;

  explicit pImpl(Rectangle *rect) : rect(rect) {}
  Rectangle *rect;

  void buildBuffers(NSObject<MTLDevice> * /*device*/);
  void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const;

  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *VertexColorBuffer_{};
  NSObject<MTLBuffer> *IndexBuffer_{};
};
