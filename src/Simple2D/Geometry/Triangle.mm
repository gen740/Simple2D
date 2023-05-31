#include "Simple2D/Geometry/Triangle.hh"

#import "Simple2D/objc/Geometry/Triangle.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <iostream>
#include <memory>

namespace Simple2D::Geometry {

Triangle::Triangle() : pimpl_(std::make_shared<pImpl>(this)) {}

Triangle::Triangle(simd::float3x3 positions, simd::float3x3 colors)
    : pimpl_(std::make_shared<pImpl>(this)) {
  this->positions = positions;
  this->colors = colors;
}

void Triangle::pImpl::buildBuffers(NSObject<MTLDevice>* device) {
  this->VertexDataBuffer_ = [device newBufferWithBytes:&this->parent_->positions
                                                length:sizeof(simd::float3x3)
                                               options:MTLResourceStorageModeManaged];
  this->VertexColorBuffer_ = [device newBufferWithBytes:&this->parent_->colors
                                                 length:sizeof(simd::float3x3)
                                                options:MTLResourceStorageModeManaged];
}

void Triangle::pImpl::draw(NSObject<MTLRenderCommandEncoder>* enc) const {
  [enc setVertexBuffer:VertexDataBuffer_ offset:0 atIndex:0];
  [enc setVertexBuffer:VertexColorBuffer_ offset:0 atIndex:1];
  [enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
}

Triangle::pImpl::~pImpl() {
  [VertexDataBuffer_ release];
  [VertexColorBuffer_ release];
}

}  // namespace Simple2D::Geometry
