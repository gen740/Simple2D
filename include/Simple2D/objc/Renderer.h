#include "Simple2D/Simple2D.hh"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <atomic>

#include <iostream>
#include <semaphore>

class Renderer {
 public:
  explicit Renderer(NSObject<MTLDevice> *pDevice,
                    std::list<Simple2D::Geometry::Geometry_var> *geometries, MTKView *view_);
  ~Renderer();

  void buildShaders();
  void buildBuffers();

  void draw(MTKView *pView);
  void addGeometry(const Simple2D::Geometry::Geometry_var &geometry);

  void saveImage(NSString *path);

  // pause render cycle
  void pauseDraw() { this->render_flag.store(false); }

  // resume render cycle
  void resumeDraw() { this->render_flag.store(true); };

 private:
  NSObject<MTLDevice> *_pDevice;
  NSObject<MTLCommandQueue> *_pCommandQueue;
  NSObject<MTLLibrary> *_pShaderLibrary;
  NSObject<MTLRenderPipelineState> *_pPSO{};
  NSObject<MTLDepthStencilState> *_pDSS;

  MTKView *view_;
  std::list<Simple2D::Geometry::Geometry_var> *geometries;
  static constexpr int kMaxFramesInFlight = 3;
  std::array<NSObject<MTLBuffer> *, kMaxFramesInFlight> _pInstanceDataBuffer{};
  std::counting_semaphore<kMaxFramesInFlight> _semaphore{3};

  std::atomic_bool render_flag{true};
  std::atomic_bool save_image;
  std::function<void(id<MTLTexture>)> callback{nullptr};
};
