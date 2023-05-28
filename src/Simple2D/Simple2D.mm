#include "Simple2D/Simple2D.hh"

#import "Simple2D/objc/AppDelegate.h"

#define NS_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#define MTK_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <simd/simd.h>

#include <iostream>

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

Simple2D::App::App() : pimpl(std::make_unique<Simple2D::App::Impl>(&this->geometries)) {}
Simple2D::App::~App() { std::cout << this->pimpl.get() << std::endl; }
void Simple2D::App::run() { pimpl->run(); }
