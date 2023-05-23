#include <Foundation/Foundation.h>
#include <iostream>
#include <semaphore>

#include "Simple2D/Geometry/Triangle.h"
#import "Simple2D/Geometry/internal/TrianglePimpl.h"
#include "Simple2D/Simple2D.h"
#import "Simple2D/internal/AppDelegate.h"
#import "Simple2D/internal/MetalDelegate.h"
#import "Simple2D/internal/shader.h"

#define NS_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#define MTK_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#include <simd/simd.h>

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#if !__has_feature(objc_arc)
#error "ARC is off"
#endif

struct Simple2D::App::Impl {
 public:
  explicit Impl(std::list<Simple2D::Geometry::Geometry_var> *geometries) : geometries(geometries) {
    this->delegate_ = [[AppDelegate alloc] initWithGeometries:geometries];
  }

  void run() {
    @autoreleasepool {
      this->pApp_ = [NSApplication sharedApplication];
      pApp_.delegate = this->delegate_;
      [pApp_ run];
    }
  }
  ~Impl() = default;

  AppDelegate *delegate_;
  NSApplication *pApp_;
  std::list<Simple2D::Geometry::Geometry_var> *geometries;
};

Simple2D::App::App() : pimpl(std::make_shared<Simple2D::App::Impl>(&this->geometries)) {}
Simple2D::App::~App() = default;

void Simple2D::App::run() { pimpl->run(); }

void Simple2D::App::addGeometry(const Geometry::Geometry_var &geometry) {
  geometries.push_back(geometry);
}
