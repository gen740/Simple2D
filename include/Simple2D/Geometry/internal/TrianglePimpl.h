#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include <Simple2D/Geometry/Triangle.h>

class Simple2D::Geometry::Triangle::pImpl {
 public:
  pImpl() = delete;

  pImpl(const pImpl &) = delete;
  pImpl(pImpl &&) = delete;
  pImpl &operator=(const pImpl &) = delete;
  pImpl &operator=(pImpl &&) = delete;

  explicit pImpl(Triangle *triangle) : triangle(triangle) {}
  Triangle *triangle;
  void buildBuffers(NSObject<MTLDevice> * /*device*/);
  void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const;
  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *VertexColorBuffer_{};
  NSObject<MTLBuffer> *IndexBuffer_{};
};
