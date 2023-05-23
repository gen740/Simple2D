#import <Simple2D/internal/Renderer.h>

#include <Simple2D/Geometry/Triangle.h>
#import <Simple2D/Geometry/internal/TrianglePimpl.h>

Renderer::Renderer(NSObject<MTLDevice> *pDevice,
                   std::list<Simple2D::Geometry::Geometry_var> *geometries)
    : geometries(geometries) {
  _pDevice = pDevice;
  _pCommandQueue = [pDevice newCommandQueue];
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
  pDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;

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
    [pCmd addCompletedHandler:[=](id<MTLCommandBuffer>) { this->_semaphore.release(1); }];

    auto *pRpd = pView.currentRenderPassDescriptor;
    auto *pEnc = [pCmd renderCommandEncoderWithDescriptor:pRpd];

    [pEnc setRenderPipelineState:_pPSO];
    for (auto &a : *geometries) {
      std::visit([&](auto &x) { x->pimpl_->draw(pEnc); }, a);
    }
    [pEnc endEncoding];
    [pCmd presentDrawable:pView.currentDrawable];
    [pCmd commit];
  }
}

void Renderer::addGeometry(const Simple2D::Geometry::Geometry_var &geometry) {
  geometries->push_back(geometry);
}
