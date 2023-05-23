#include <Simple2D/Geometry/Rectangle.hpp>
#include <Simple2D/Geometry/Triangle.hpp>
#include <Simple2D/Simple2D.hpp>
#include <iostream>

int main() {
  using Simple2D::Geometry::Rectangle;
  using Simple2D::Geometry::Triangle;
  auto app = Simple2D::App();

  auto tri = app.addGeometry<Triangle>();
  tri->colors = simd::float3x3{simd::float3{1.0, 0.3F, 0.2F},
                               simd::float3{0.8F, 1.0, 0.0F},
                               simd::float3{0.8F, 0.0F, 1.0}};
  tri->positions = simd::float3x3{
      simd::float3{-0.8F, 0.8F, 0.0F},  //
      simd::float3{0.0F, -0.8F, 0.0F},  //
      simd::float3{+0.8F, 0.8F, 0.0F}   //
  };

  auto rect = app.addGeometry<Rectangle>();
  rect->colors = simd::float4x3{
      simd::float3{1.0, 0.3F, 0.2F},  //
      simd::float3{0.8F, 1.0, 0.0F},  //
      simd::float3{0.8F, 1.0, 0.0F},  //
      simd::float3{0.8F, 0.0F, 1.0}   //
  };
  rect->positions = simd::float4x3{
      simd::float3{-0.5F, 0.5F, 0.2F},  //
      simd::float3{0.5F, 0.5F, 0.2F},   //
      simd::float3{0.5F, -0.5F, 0.2F},  //
      simd::float3{-0.5F, -0.5F, 0.2F}  //
  };

  app.run();
  return 0;
}
