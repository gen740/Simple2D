#include "Simple2D/Geometry/Rectangle.hh"
#include <array>

#import "Simple2D/objc/Geometry/Rectangle.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <iostream>
#include <memory>

namespace Simple2D::Geometry {

Rectangle::Rectangle() : pimpl_(std::make_shared<pImpl>(this)) {}

void Rectangle::pImpl::buildBuffers(NSObject<MTLDevice>* device) {
  VertexDataBuffer_ = [device newBufferWithBytes:&this->parent_->positions
                                          length:sizeof(simd::float4x3)
                                         options:MTLResourceStorageModeManaged];
  VertexColorBuffer_ = [device newBufferWithBytes:&this->parent_->colors
                                           length:sizeof(simd::float4x3)
                                          options:MTLResourceStorageModeManaged];
  std::array<uint16, 6> indexes{0, 1, 2, 0, 2, 3};
  IndexBuffer_ = [device newBufferWithBytes:indexes.data()
                                     length:6 * sizeof(uint16)
                                    options:MTLResourceStorageModeManaged];
}

void Rectangle::pImpl::draw(NSObject<MTLRenderCommandEncoder>* enc) const {
  [enc setVertexBuffer:VertexDataBuffer_ offset:0 atIndex:0];
  [enc setVertexBuffer:VertexColorBuffer_ offset:0 atIndex:1];
  [enc drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                  indexCount:6
                   indexType:MTLIndexTypeUInt16
                 indexBuffer:IndexBuffer_
           indexBufferOffset:0];
}

}  // namespace Simple2D::Geometry
