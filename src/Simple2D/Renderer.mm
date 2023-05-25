#import "Simple2D/objc/Renderer.h"
#import "Simple2D/objc/Geometry/Rectangle.h"
#import "Simple2D/objc/Geometry/Triangle.h"

#include <CoreGraphics/CGImage.h>

Renderer::Renderer(NSObject<MTLDevice> *pDevice,
                   std::list<Simple2D::Geometry::Geometry_var> *geometries, MTKView *view_)
    : view_(view_), geometries(geometries) {
  _pDevice = pDevice;
  _pCommandQueue = [pDevice newCommandQueue];

  view_.framebufferOnly = NO;
  ((CAMetalLayer *)view_.layer).allowsNextDrawableTimeout = NO;
  view_.colorPixelFormat = MTLPixelFormatBGRA8Unorm;

  buildShaders();
  buildBuffers();
}

Renderer::~Renderer() = default;

void Renderer::buildShaders() {
  NSError *pError;

  auto *pLibrary =
      [_pDevice newLibraryWithSource:[NSString stringWithUTF8String:Simple2D::Shader::ShaderSrc]
                             options:nullptr
                               error:&pError];
  if (pLibrary == nullptr) {
    std::cout << pError.localizedDescription.UTF8String << std::endl;
    assert(false);
  }

  auto pVertexFn = [pLibrary newFunctionWithName:@"vertexMain"];
  auto pFragFn = [pLibrary newFunctionWithName:@"fragmentMain"];
  auto *pDesc = [[MTLRenderPipelineDescriptor alloc] init];
  [pDesc setVertexFunction:pVertexFn];
  [pDesc setFragmentFunction:pFragFn];
  std::cout << view_.colorPixelFormat << std::endl;
  pDesc.colorAttachments[0].pixelFormat = view_.colorPixelFormat;

  _pPSO = [_pDevice newRenderPipelineStateWithDescriptor:pDesc error:&pError];
  if (_pPSO == nullptr) {
    std::cout << pError.localizedDescription.UTF8String << std::endl;
    assert(false);
  }
  _pShaderLibrary = pLibrary;
}

void Renderer::buildBuffers() {
  for (auto &a : *geometries) {
    std::visit([=](auto &x) { x->pimpl_->buildBuffers(_pDevice); }, a);
  }
}

void Renderer::draw(MTKView *pView) {
  @autoreleasepool {
    auto *pCmd = [_pCommandQueue commandBuffer];

    _semaphore.acquire();

    static int counter = 0;
    counter++;

    [pCmd addCompletedHandler:[=](id<MTLCommandBuffer>) { this->_semaphore.release(1); }];

    auto *pEnc = [pCmd renderCommandEncoderWithDescriptor:pView.currentRenderPassDescriptor];

    [pEnc setRenderPipelineState:_pPSO];

    for (auto &geometry : *geometries) {
      std::visit([&](auto &x) { x->pimpl_->draw(pEnc); }, geometry);
    }

    [pEnc endEncoding];

    if (counter == 60) {
      auto texture = pView.currentDrawable.texture;
      std::cout << texture.bufferBytesPerRow << std::endl;
      auto image = [CIImage imageWithMTLTexture:texture options:nullptr];
    }
    [pCmd presentDrawable:pView.currentDrawable];
    [pCmd commit];
  }
}

void Renderer::addGeometry(const Simple2D::Geometry::Geometry_var &geometry) {
  geometries->push_back(geometry);
}
