#include <Simple2D/Geometry/Line.hh>
#include <Simple2D/Geometry/Triangle.hh>
#include <Simple2D/Simple2D.hh>
#include <iostream>
#include <vector>

int main() {
  using Simple2D::Geometry::Line;
  using Simple2D::Geometry::Triangle;
  auto app = Simple2D::App();

  auto tri = app.addGeometry<Line>(
      std::vector{
          simd::float3{-0.8F, 0.2F, 0.2F},   //
          simd::float3{-0.8F, 0.8F, 0.2F},   //
          simd::float3{-0.2F, 0.2F, 0.2F},   //
          simd::float3{-0.2F, 0.8F, 0.2F},   //
          simd::float3{0.2F, 0.8F, 0.2F},    //
          simd::float3{0.8F, 0.2F, 0.2F},    //
          simd::float3{0.8F, 0.8F, 0.2F},    //
          simd::float3{0.2F, 0.2F, 0.2F},    //
          simd::float3{0.2F, -0.2F, 0.2F},   //
          simd::float3{0.8F, -0.2F, 0.2F},   //
          simd::float3{0.8F, -0.8F, 0.2F},   //
          simd::float3{0.2F, -0.8F, 0.2F},   //
          simd::float3{-0.2F, -0.2F, 0.2F},  //
          simd::float3{-0.8F, -0.8F, 0.2F},  //
          simd::float3{-0.8F, -0.2F, 0.2F},  //
          simd::float3{-0.2F, -0.8F, 0.2F}   //
      },
      std::vector{
          simd::float3{1.0F, 0.3F, 0.2F},  //
          simd::float3{0.8F, 0.0F, 0.0F},  //
          simd::float3{0.8F, 0.0F, 0.0F},  //
          simd::float3{0.8F, 0.8F, 0.0F},  //
          simd::float3{0.8F, 0.8F, 0.2F},  //
          simd::float3{0.8F, 0.0F, 0.0F},  //
          simd::float3{0.5F, 0.0F, 0.0F},  //
          simd::float3{0.5F, 0.0F, 0.0F},  //
          simd::float3{0.5F, 0.0F, 0.0F},  //
          simd::float3{0.5F, 0.0F, 0.0F},  //
          simd::float3{0.5F, 0.8F, 0.0F},  //
          simd::float3{0.3F, 0.8F, 0.0F},  //
          simd::float3{0.3F, 0.8F, 0.0F},  //
          simd::float3{0.3F, 0.8F, 0.2F},  //
          simd::float3{0.3F, 0.0F, 0.2F},  //
          simd::float3{0.3F, 0.0F, 0.2F}   //
      },
      0.05);

  app.addGeometry<Line>(
      std::vector{
          simd::float3{-0.8F, 0.8F, 0.3F},  //
          simd::float3{0.8F, -0.8F, 0.1F},  //
          simd::float3{0.8F, 0.8F, 0.1F},   //
          simd::float3{-0.8F, -0.8F, 0.1F}  //
      },
      std::vector{
          simd::float3{1.0F, 1.0F, 1.0F},  //
          simd::float3{1.0F, 1.0F, 1.0F},  //
          simd::float3{1.0F, 1.0F, 1.0F},  //
          simd::float3{1.0F, 1.0F, 1.0F}   //
      },
      0.1);

  app.run();
  return 0;
}
