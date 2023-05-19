#pragma once

#include <memory>
namespace Simple2D {

class App {
 public:
  App();
  void run();

 private:
  class Impl;
  std::shared_ptr<Impl> pimpl;
};

}  // namespace Simple2D
