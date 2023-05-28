#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "Simple2D/Geometry/Triangle.hh"
#import "Simple2D/objc/Renderer.h"

namespace Simple2D::Geometry {

template <class Parent>
class pImplBase {
 public:
  pImplBase() = delete;
  explicit pImplBase(Parent *parent) : parent_(parent) {}

  pImplBase(const pImplBase &) = delete;
  pImplBase(pImplBase &&) = delete;
  pImplBase &operator=(const pImplBase &) = delete;
  pImplBase &operator=(pImplBase &&) = delete;

  Parent *parent_;

  virtual void buildBuffers(NSObject<MTLDevice> * /*device*/) = 0;
  virtual void draw(NSObject<MTLRenderCommandEncoder> * /*enc*/) const = 0;
};

}  // namespace Simple2D::Geometry
