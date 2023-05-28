#pragma once
#include <simd/simd.h>

#include <vector>

namespace Simple2D::Geometry {

class Line {
  using float3 = simd::float3;

 public:
  Line();
  Line(std::vector<float3> positions, std::vector<float3> colors,
       float width = 0.1);

  Line(const Line &) = delete;
  Line(Line &&) = delete;
  Line &operator=(const Line &) = delete;
  Line &operator=(Line &&) = delete;

  void addPoint(float3 point, float3 color);
  void setWidth(float width) { this->width_ = width; }

  class pImpl;
  std::shared_ptr<pImpl> pimpl_{};

 private:
  std::vector<float3> positions_;
  std::vector<float3> colors_;

  uint16_t pointNum_{0};

  float width_{0.1};
};

}  // namespace Simple2D::Geometry
