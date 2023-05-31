#import "Simple2D/objc/Renderer.h"
#include <AppKit/AppKit.h>
#include <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "Simple2D/objc/Geometry/Line.h"
#import "Simple2D/objc/Geometry/Rectangle.h"
#import "Simple2D/objc/Geometry/Triangle.h"

#include <CoreGraphics/CGImage.h>
#include <CoreImage/CIContext.h>
#include <CoreImage/CIImage.h>

#include <ImageIO/ImageIO.h>

Renderer::Renderer(NSObject<MTLDevice> *pDevice,
                   std::list<Simple2D::Geometry::Geometry_var> *geometries, MTKView *view_)
    : view_(view_), geometries(geometries) {
  device_ = pDevice;
  commandQueue_ = [pDevice newCommandQueue];

  view_.framebufferOnly = NO;
  ((CAMetalLayer *)view_.layer).allowsNextDrawableTimeout = NO;
  view_.colorPixelFormat = MTLPixelFormatBGRA8Unorm;

  buildShaders();
  buildBuffers();
}

Renderer::~Renderer() {
  [this->DSS_ release];
  [this->PSO_ release];
  [this->shaderLibrary_ release];
  [this->commandQueue_ release];
  [this->device_ release];
};

void Renderer::buildShaders() {
  @autoreleasepool {
    NSError *pError;
    NSString *metallibPath = [[[NSBundle mainBundle] pathForResource:@"metallib/Simple2D"
                                                              ofType:@"metallib"]
        stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                               URLUserAllowedCharacterSet]];

    NSObject<MTLLibrary> *shaderLibrary =
        [device_ newLibraryWithURL:[NSURL URLWithString:metallibPath] error:&pError];
    this->shaderLibrary_ = shaderLibrary;
    if (shaderLibrary == nullptr) {
      std::cout << pError.localizedDescription.UTF8String << std::endl;
      assert(false);
    }

    id<MTLFunction> pVertexFn = [shaderLibrary newFunctionWithName:@"vertexMain"].autorelease;
    id<MTLFunction> pFragFn = [shaderLibrary newFunctionWithName:@"fragmentMain"].autorelease;
    auto *pDesc = MTLRenderPipelineDescriptor.alloc.init.autorelease;

    pDesc.vertexFunction = pVertexFn;
    pDesc.fragmentFunction = pFragFn;
    pDesc.rasterSampleCount = this->view_.sampleCount;
    pDesc.colorAttachments[0].pixelFormat = view_.colorPixelFormat;
    pDesc.depthAttachmentPixelFormat = view_.depthStencilPixelFormat;
    MTLDepthStencilDescriptor *depthStencilStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStencilStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilStateDesc.depthWriteEnabled = YES;
    this->DSS_ = [this->device_ newDepthStencilStateWithDescriptor:depthStencilStateDesc];

    this->PSO_ = [device_ newRenderPipelineStateWithDescriptor:pDesc error:&pError];
    if (this->PSO_ == nullptr) {
      std::cout << pError.localizedDescription.UTF8String << std::endl;
      assert(false);
    }
  }
}

void Renderer::buildBuffers() {
  for (auto &a : *geometries) {
    std::visit([=](auto &x) { x->pimpl_->buildBuffers(device_); }, a);
  }
}

void Renderer::draw(MTKView *pView) {
  @autoreleasepool {
    NSObject<MTLCommandBuffer> *cmd = this->commandQueue_.commandBuffer;
    MTLRenderPassDescriptor *rpd = pView.currentRenderPassDescriptor;
    NSObject<MTLRenderCommandEncoder> *enc = [cmd renderCommandEncoderWithDescriptor:rpd];

    [enc setRenderPipelineState:this->PSO_];
    [enc setDepthStencilState:this->DSS_];

    for (auto &geometry : *geometries) {
      std::visit([&](auto &x) { x->pimpl_->draw(enc); }, geometry);
    }
    [enc endEncoding];

    // [pCmd addCompletedHandler:[&](id<MTLCommandBuffer>) {

    //   std::cout << "Save" << std::endl;
    //   auto *ciImage = [[CIImage alloc] initWithMTLTexture:this->view_.currentDrawable.texture
    //                                               options:nullptr];
    //
    //   CGImageRef cgImage = [[CIContext context] createCGImage:ciImage fromRect:[ciImage extent]];
    //   NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    //   NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG
    //   properties:@{}];
    //
    //   [pngData writeToFile:@"./hoge.png" atomically:NO];
    // }];

    [cmd presentDrawable:pView.currentDrawable];
    [cmd commit];
  }
}

void Renderer::addGeometry(const Simple2D::Geometry::Geometry_var &geometry) {
  geometries->push_back(geometry);
}

void Renderer::saveImage(NSString *path) {}
