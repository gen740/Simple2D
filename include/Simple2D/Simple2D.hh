#pragma once

#include <concepts>
#include <iostream>
#include <list>
#include <memory>
#include <variant>

namespace Simple2D {

namespace Geometry {
class Triangle;
class Rectangle;
class Line;

using Geometry_var =
    std::variant<std::shared_ptr<Triangle>, std::shared_ptr<Rectangle>,
                 std::shared_ptr<Line>>;

}  // namespace Geometry

class App {
 public:
  App();
  ~App();
  void run();

  template <class T, class... Args>
  std::shared_ptr<T> addGeometry(Args... args) {
    auto geometry = std::make_shared<T>(args...);
    geometries.push_back(geometry);
    return geometry;
  }

  void addGeometry(const Geometry::Geometry_var& geometry) {
    geometries.push_back(geometry);
  }

 private:
  std::list<Simple2D::Geometry::Geometry_var> geometries{};
  struct Impl;
  std::unique_ptr<Impl> pimpl;
};

}  // namespace Simple2D
