cmake_minimum_required(VERSION 3.0)
project(GLOW
  LANGUAGES Fortran
  VERSION 0.981)

add_compile_options(-O3)
if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
  list(APPEND old -std=legacy -w)
  list(APPEND new -std=f2018)
endif()

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)

set(snoem_src snoem.f90 snoemint.f90 geomag.f90)

set(utils_src mzgrid.f90 conduct.f90 nrlmsise00.f iri90.f)

add_library(cglow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(cglow PRIVATE ${old})

add_executable(glow.bin glowpython.f90 utils.f90 fsutils.f90)
target_link_libraries(glow.bin cglow)
target_compile_options(glow.bin PRIVATE ${new})
