#import "Simple2D/objc/Renderer.h"
#import "Simple2D/objc/Geometry/Line.h"
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
  pDesc.vertexFunction = pVertexFn;
  pDesc.fragmentFunction = pFragFn;
  pDesc.rasterSampleCount = this->view_.sampleCount;
  pDesc.colorAttachments[0].pixelFormat = view_.colorPixelFormat;
  pDesc.depthAttachmentPixelFormat = view_.depthStencilPixelFormat;
  MTLDepthStencilDescriptor *depthStencilStateDesc = [[MTLDepthStencilDescriptor alloc] init];
  depthStencilStateDesc.depthCompareFunction = MTLCompareFunctionLess;
  depthStencilStateDesc.depthWriteEnabled = YES;
  this->_pDSS = [this->_pDevice newDepthStencilStateWithDescriptor:depthStencilStateDesc];

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

    auto *pEnc = [pCmd renderCommandEncoderWithDescriptor:pView.currentRenderPassDescriptor];

    [pEnc setRenderPipelineState:this->_pPSO];
    [pEnc setDepthStencilState:this->_pDSS];

    for (auto &geometry : *geometries) {
      std::visit([&](auto &x) { x->pimpl_->draw(pEnc); }, geometry);
    }

    [pEnc endEncoding];

    [pCmd presentDrawable:pView.currentDrawable];
    [pCmd commit];
  }
}

void Renderer::addGeometry(const Simple2D::Geometry::Geometry_var &geometry) {
  geometries->push_back(geometry);
}
