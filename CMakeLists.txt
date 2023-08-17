cmake_minimum_required(VERSION 3.14...3.27)

project(GLOW
LANGUAGES Fortran
VERSION 0.981
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})

add_subdirectory(src/ncarglow)
