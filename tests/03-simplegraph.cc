#include <Simple2D/Geometry/Line.hh>
#include <Simple2D/Simple2D.hh>

using Simple2D::Geometry::Line;
int main() {
  auto app = Simple2D::App();

  auto line = app.addGeometry<Line>();

  line->setWidth(0.01);

  for (int i = 0; i < 1000; i++) {
    float t = 0.001F * i;
    float p = (2 * t - 1);
    line->addPoint({p, 2 * p * p - 1.0F, 0}, {1, 1 - t, t});
  }

  app.run();
  return 0;
}
