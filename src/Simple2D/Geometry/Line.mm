#include "Simple2D/Geometry/Line.hh"
#include <array>

#import "Simple2D/objc/Geometry/Line.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <simd/simd.h>
#include <cstddef>
#include <iostream>
#include <memory>
#include <utility>

namespace Simple2D::Geometry {

using simd::float3;

Line::Line() : pimpl_(std::make_shared<pImpl>(this)) {}

Line::Line(std::vector<float3> positions, std::vector<float3> colors, float width)
    : pimpl_(std::make_shared<pImpl>(this)),
      positions_(std::move(positions)),
      colors_(std::move(colors)),
      width_(width) {
  if (positions_.size() != colors_.size()) {
    std::cerr << "Does not much size of points and colos in class Line" << std::endl;
    throw std::runtime_error("Geometry Error");
  }
  pointNum_ = positions_.size();
}

void Line::addPoint(float3 point, float3 color) {
  this->positions_.push_back(point);
  this->colors_.push_back(color);
  pointNum_++;
}

void Line::pImpl::buildBuffers(NSObject<MTLDevice>* device) {
  auto normalize = [](float3 vec) { return vec / std::hypot(vec[0], vec[1], vec[2]); };
  auto dot = [](float3 v1, float3 v2) {
    float ret = 0;
    for (int i = 0; i < 3; i++) {
      ret += v1[i] * v2[i];
    }
    return ret;
  };

  std::vector<float3> vertexes;
  std::vector<float3> colors;
  std::vector<uint16_t> indexes;

  std::vector<float3> eVec;

  auto N = this->parent_->pointNum_;
  eVec.reserve(N - 1);
  for (int i = 0; i < N - 1; i++) {
    eVec.emplace_back(
        normalize(this->parent_->positions_.at(i + 1) - this->parent_->positions_.at(i)));
  }
  for (int i = 0; i < N - 1; i++) {
    indexes.push_back(2 * i);
    indexes.push_back(2 * i + 1);
    indexes.push_back(2 * i + 2);
    indexes.push_back(2 * i + 1);
    indexes.push_back(2 * i + 3);
    indexes.push_back(2 * i + 2);
  }

  for (int i = 0; i < N; i++) {
    float3 v;
    static float3 vpre;
    if (i == 0) {
      v = eVec.at(0) + eVec.at(1);
      v -= dot(v, eVec.at(0)) * eVec.at(0);
      v = normalize(v);
      vpre = v;

    } else if (i == (N - 1)) {
      v = eVec.at(i - 1) - eVec.at(i - 2);
      v -= dot(v, eVec.at(i - 1)) * eVec.at(i - 1);
      v = normalize(v);

      vpre -= dot(vpre, eVec.at(i - 1)) * eVec.at(i - 1);
      if (dot(v, vpre) < 0) {
        v *= -1;
      }

    } else {
      v = eVec[i] - eVec[i - 1];
      v = normalize(v);

      vpre -= dot(vpre, eVec.at(i - 1)) * eVec.at(i - 1);
      if (dot(v, vpre) < 0) {
        v *= -1;
      }
      vpre = normalize(v);

      v *= 1 / std::sqrt(1 - dot(v, eVec[i]) * dot(v, eVec[i]));
    }
    vertexes.push_back(this->parent_->positions_[i] + this->parent_->width_ * v);
    vertexes.push_back(this->parent_->positions_[i] - this->parent_->width_ * v);
    colors.push_back(this->parent_->colors_[i]);
    colors.push_back(this->parent_->colors_[i]);
  }

  VertexDataBuffer_ = [device newBufferWithBytes:vertexes.data()
                                          length:2UL * N * sizeof(simd::float3)
                                         options:MTLResourceStorageModeManaged];
  VertexColorBuffer_ = [device newBufferWithBytes:colors.data()
                                           length:2UL * N * sizeof(simd::float3)
                                          options:MTLResourceStorageModeManaged];
  IndexBuffer_ = [device newBufferWithBytes:indexes.data()
                                     length:indexes.size() * sizeof(uint16)
                                    options:MTLResourceStorageModeManaged];
}

void Line::pImpl::draw(NSObject<MTLRenderCommandEncoder>* enc) const {
  [enc setVertexBuffer:VertexDataBuffer_ offset:0 atIndex:0];
  [enc setVertexBuffer:VertexColorBuffer_ offset:0 atIndex:1];
  [enc drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                  indexCount:6L * (this->parent_->pointNum_ - 1)
                   indexType:MTLIndexTypeUInt16
                 indexBuffer:IndexBuffer_
           indexBufferOffset:0];
}

}  // namespace Simple2D::Geometry
