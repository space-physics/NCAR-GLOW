cmake_minimum_required(VERSION 3.0)
project(GLOW Fortran)

add_library(cglow 
  glow.f90 cglow.f90 
  fieldm.f solzen.f90 ssflux.f90
  rcolum.f90 qback.f90
  etrans.f90 exsect.f
  gchem.f90 bands.f90 
  #qproton.f90
  ephoto.f90
  egrid.f90 maxt.f90)

target_compile_options(cglow PRIVATE -w)

