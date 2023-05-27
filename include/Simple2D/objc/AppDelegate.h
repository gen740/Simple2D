#include <AppKit/AppKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Simple2D/objc/MetalDelegate.h>
#import <Simple2D/Simple2D.hh>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
- (AppDelegate *)initWithGeometries:(std::list<Simple2D::Geometry::Geometry_var> *)geometries;

// Main Window
@property(strong, nonatomic) NSWindow *window_;

// Input Window
@property(strong, nonatomic) NSWindow *inputWindow_;
@property(strong, nonatomic) NSTextField *textField_;

// Metal things
@property(strong, nonatomic) id<MTLDevice> device_;
@property(strong, nonatomic) MTKView *metalView_;
@property(strong, nonatomic) MyMetalDelegate *metalDelegate_;

@property(assign, nonatomic) std::list<Simple2D::Geometry::Geometry_var> *geometries_;
@property(NS_NONATOMIC_IOSONLY, readonly, copy) NSMenu *createMenuBar_;

// actions
- (void)appQuit:(id)sender;
- (void)windowClose:(id)sender;
- (void)saveAction:(id)seder;
- (void)saveImage;
- (void)closeInputWindow;
@end
