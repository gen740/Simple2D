#pragma once
#include <MetalKit/MetalKit.h>

#include <memory>

namespace Simple2D::Geometry {

class Base {
 public:
  Base() = default;
  virtual ~Base() = default;

  class pImpl;
  std::shared_ptr<pImpl> pimpl_;
};

class Base::pImpl {
 public:
  NSObject<MTLBuffer> *VertexDataBuffer_{};
  NSObject<MTLBuffer> *IndexBuffer_{};

  virtual void buildBuffer(NSObject<MTLDevice> * /*device*/);
  virtual void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/);
};

}  // namespace Simple2D::Geometry
