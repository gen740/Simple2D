#pragma once
#include <simd/simd.h>

#include <vector>

namespace Simple2D::Geometry {

class Triangle {
 public:
  Triangle();
  Triangle(const Triangle &) = delete;
  Triangle(Triangle &&) = delete;
  Triangle &operator=(const Triangle &) = delete;
  Triangle &operator=(Triangle &&) = delete;
  // Triangle(simd::float3x3 vertexes, simd::float3x3 colors);

  simd::float3x3 positions;
  simd::float3x3 colors;

  class pImpl;
  std::shared_ptr<pImpl> pimpl_{};
};

}  // namespace Simple2D::Geometry
