#include <Simple2D/Simple2D.h>

#include <iostream>

#include "Simple2D/Geometry/Triangle.h"

int main() {
  auto app = Simple2D::App();

  auto tri = std::make_shared<Simple2D::Geometry::Triangle>();
  tri->colors = simd::float3x3{simd::float3{1, 1, 1}, simd::float3{1, 1, 1},
                               simd::float3{1, 1, 1}};
  tri->positions = simd::float3x3{
      simd::float3{-0.8F, 0.8F, 0.0F},  //
      simd::float3{0.0F, -0.8F, 0.0F},  //
      simd::float3{+0.8F, 0.8F, 0.0F}   //
  };
  app.addGeometry(tri);
  app.run();
  return 0;
}
