cmake_minimum_required(VERSION 3.15)

project(MyCudaProject LANGUAGES CXX CUDA)

enable_language(CUDA)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-std=c++20;-gencode arch=compute_86,code=sm_86)

add_subdirectory(import_opencv)
add_subdirectory(import_cuda)