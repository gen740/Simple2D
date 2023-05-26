#pragma once
#include <simd/simd.h>

#include <vector>

namespace Simple2D::Geometry {

class Rectangle {
 public:
  Rectangle();
  Rectangle(const Rectangle &) = delete;
  Rectangle(Rectangle &&) = delete;
  Rectangle &operator=(const Rectangle &) = delete;
  Rectangle &operator=(Rectangle &&) = delete;

  simd::float4x3 positions;
  simd::float4x3 colors;

  class pImpl;
  std::shared_ptr<pImpl> pimpl_{};
};

}  // namespace Simple2D::Geometry
