#pragma once

#include <concepts>
#include <list>
#include <memory>
#include <variant>

namespace Simple2D {

namespace Geometry {
class Triangle;

using Geometry_var = std::variant<std::shared_ptr<Triangle>>;
}  // namespace Geometry

class App {
 public:
  App();
  ~App();
  void createCanvas();
  void run();

  // template <class T>
  // std::shared_ptr<T> addGeometry();

  void addGeometry(const Geometry::Geometry_var&);

 private:
  std::list<Simple2D::Geometry::Geometry_var> geometries{};
  struct Impl;
  std::shared_ptr<Impl> pimpl;
};

}  // namespace Simple2D
