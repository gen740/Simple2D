cmake_minimum_required(VERSION 3.20)

project(Simple2D CXX OBJCXX)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_LIST_DIR})
  set(SIMPLE2D_TESTING ON)
  set(CMAKE_EXPORT_COMPILE_COMMANDS on)
else()
  set(SIMPLE2D_TESTING OFF)
  set(CMAKE_EXPORT_COMPILE_COMMANDS off)
endif()

file(
  GLOB
  SIMPLE2D_SOURCES #
  ${CMAKE_CURRENT_LIST_DIR}/src/*.cc #
  ${CMAKE_CURRENT_LIST_DIR}/src/**/*.cc #
  ${CMAKE_CURRENT_LIST_DIR}/src/*.mm #
  ${CMAKE_CURRENT_LIST_DIR}/src/**/*.mm #
)

add_library(${PROJECT_NAME} ${SIMPLE2D_SOURCES})

set(CMAKE_CXX_STANDARD 20)

target_link_libraries(
  ${PROJECT_NAME}
  PRIVATE
    "-framework Metal -framework Foundation -framework Cocoa -framework CoreGraphics -framework MetalKit"
)

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/include
)

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++20" COMPILER_SUPPORTS_CXX20)
set(CMAKE_CXX_FLAGS "-std=c++20 ${CMAKE_CXX_FLAGS}")

if(${SIMPLE2D_TESTING})

  file(GLOB SIMPLE2D_TESTING_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tests/*.cc)
  add_compile_options(-O3)
  foreach(TEST ${SIMPLE2D_TESTING_SOURCES})
    get_filename_component(TEST_NAME ${TEST} NAME_WE)
    add_executable(${TEST_NAME} ${TEST})
    target_link_libraries(${TEST_NAME} Simple2D)
  endforeach()
endif()
