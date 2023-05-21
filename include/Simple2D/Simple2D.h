#pragma once

#include <memory>
namespace Simple2D {

class App {
 public:
  App();
  ~App();
  void createCanvas();
  void run();

 private:
  struct Impl;
  std::shared_ptr<Impl> pimpl;
};

}  // namespace Simple2D
