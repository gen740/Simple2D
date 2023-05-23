#include "Simple2D/Simple2D.hpp"
#import "Simple2D/objc/shader.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <iostream>
#include <semaphore>

class Renderer {
 public:
  explicit Renderer(NSObject<MTLDevice> *pDevice,
                    std::list<Simple2D::Geometry::Geometry_var> *geometries);
  ~Renderer();

  void buildShaders();
  void buildBuffers();

  void draw(MTKView *pView);
  void addGeometry(const Simple2D::Geometry::Geometry_var &geometry);

 private:
  NSObject<MTLDevice> *_pDevice;
  NSObject<MTLCommandQueue> *_pCommandQueue;
  NSObject<MTLLibrary> *_pShaderLibrary;
  NSObject<MTLRenderPipelineState> *_pPSO{};
  std::list<Simple2D::Geometry::Geometry_var> *geometries;
  static constexpr int kMaxFramesInFlight = 3;
  std::array<NSObject<MTLBuffer> *, kMaxFramesInFlight> _pInstanceDataBuffer{};
  std::counting_semaphore<kMaxFramesInFlight> _semaphore{3};
};
