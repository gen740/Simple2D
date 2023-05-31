cmake_minimum_required(VERSION 3.20)

project(Simple2D CXX OBJCXX)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_LIST_DIR})
  set(SIMPLE2D_TESTING ON)
  set(CMAKE_EXPORT_COMPILE_COMMANDS on)
else()
  set(SIMPLE2D_TESTING OFF)
  set(CMAKE_EXPORT_COMPILE_COMMANDS off)
endif()

# Setting Build Type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")

# Building Metal

set(SHADER_SOURCE ${CMAKE_CURRENT_LIST_DIR}/src/Simple2D.metal)
set(SHADER_AIR ${CMAKE_CURRENT_BINARY_DIR}/Simple2D.air)
set(SHADER_METALLIB ${CMAKE_CURRENT_BINARY_DIR}/Simple2D.metallib)

find_program(XRUN xrun)

add_custom_command(
  OUTPUT ${SHADER_METALLIB}
  COMMAND xcrun -sdk macosx metal -c ${SHADER_SOURCE} -o ${SHADER_AIR} #
          && xcrun -sdk macosx metallib ${SHADER_AIR} -o ${SHADER_METALLIB}
  DEPENDS ${SHADER_SOURCE}
  COMMENT "Building Metal shader")

add_custom_target(simple2d_metallib ALL DEPENDS ${SHADER_METALLIB})
set_source_files_properties(
  ${SHADER_METALLIB} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/metallib")

file(
  GLOB
  SIMPLE2D_SOURCES #
  ${CMAKE_CURRENT_LIST_DIR}/src/*.cc #
  ${CMAKE_CURRENT_LIST_DIR}/src/**/*.cc #
  ${CMAKE_CURRENT_LIST_DIR}/src/*.mm #
  ${CMAKE_CURRENT_LIST_DIR}/src/**/*.mm #
  ${CMAKE_CURRENT_LIST_DIR}/src/**/**/*.mm #
)

add_library(${PROJECT_NAME} ${SIMPLE2D_SOURCES})
add_dependencies(${PROJECT_NAME} simple2d_metallib)

file(GLOB SIMPLE2D_ICONS ${CMAKE_CURRENT_LIST_DIR}/icons/*.png)
set_source_files_properties(
    ${SIMPLE2D_ICONS} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/icons")

target_sources(${PROJECT_NAME} PUBLIC ${SHADER_METALLIB} ${SIMPLE2D_ICONS})
# target_compile_definitions( ${PROJECT_NAME} PRIVATE
# SIMPLE2D_SHADER_LIBRARY=@"${SHADER_METALLIB}")

target_link_libraries(
  ${PROJECT_NAME}
  PRIVATE "-framework Metal" #
          "-framework Foundation" #
          "-framework Cocoa" #
          "-framework CoreGraphics" #
          "-framework CoreImage" #
          "-framework MetalKit" #
)
set_property(
  TARGET ${PROJECT_NAME}
  APPEND_STRING
  PROPERTY COMPILE_FLAGS "-fobjc-arc")
set_property(TARGET ${PROJECT_NAME} PROPERTY OBJCXX_STANDARD 20)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)

target_include_directories(${PROJECT_NAME}
                           PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)

if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
  add_compile_options(-O3)
else()
  # ASAN_OPTIONS=detect_leaks=1
  add_compile_options(-Werror -g3)
  target_link_libraries(${PROJECT_NAME} PRIVATE "-fsanitize=address")
endif()

if(${SIMPLE2D_TESTING})
  file(GLOB SIMPLE2D_TESTING_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tests/*.cc)
  foreach(TEST ${SIMPLE2D_TESTING_SOURCES})
    get_filename_component(TEST_NAME ${TEST} NAME_WE)
    add_executable(${TEST_NAME} MACOSX_BUNDLE ${TEST})
    target_link_libraries(${TEST_NAME} PRIVATE Simple2D "-fsanitize=address")
    set_property(TARGET ${TEST_NAME} PROPERTY CXX_STANDARD 20)
  endforeach()
endif()
