cmake_minimum_required(VERSION 3.14...3.26)

project(GLOW
  LANGUAGES Fortran
  VERSION 0.981)

enable_testing()

option(mpiglow "build MPI driver")

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(old -w -std=legacy)
  set(new -fimplicit-none -fno-backtrace)
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  if(WIN32)
    set(old /w)
    set(new /warn:declarations /W1)
  else()
    set(old -w)
    set(new -warn declarations -W1)
  endif()
else()
  set(old -w)
endif()

add_library(cglow)
target_compile_options(cglow PRIVATE ${old})

add_executable(glow.bin)
target_link_libraries(glow.bin cglow)
target_compile_options(glow.bin PRIVATE ${new})

add_subdirectory(fortran)
