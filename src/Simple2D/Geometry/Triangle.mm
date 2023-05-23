#include "Simple2D/Geometry/Triangle.hpp"

#import "Simple2D/objc/Geometry/Triangle.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <iostream>
#include <memory>

namespace Simple2D::Geometry {

Triangle::Triangle() : pimpl_(std::make_shared<pImpl>(this)) {}
// Triangle::Triangle(simd::float3x3 vertexes, simd::float3x3 colors)
//     : vertexes(vertexes), colors(colors), pimpl_(std::make_shared<pImpl>(this)) {}

void Triangle::pImpl::buildBuffers(NSObject<MTLDevice>* device) {
  VertexDataBuffer_ = [device newBufferWithBytes:&triangle->positions
                                          length:sizeof(simd::float3x3)
                                         options:MTLResourceStorageModeManaged];
  VertexColorBuffer_ = [device newBufferWithBytes:&triangle->colors
                                           length:sizeof(simd::float3x3)
                                          options:MTLResourceStorageModeManaged];
}

void Triangle::pImpl::draw(NSObject<MTLRenderCommandEncoder>* enc) const {
  [enc setVertexBuffer:VertexDataBuffer_ offset:0 atIndex:0];
  [enc setVertexBuffer:VertexColorBuffer_ offset:0 atIndex:1];
  [enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
}

}  // namespace Simple2D::Geometry
