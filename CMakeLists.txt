cmake_minimum_required(VERSION 3.0)
project(GLOW
  LANGUAGES Fortran
  VERSION 0.981)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

add_compile_options(-O3)
if(CMAKE_Fortran_COMPILER_ID STREQUAL GCC)

  list(APPEND old -w)

  if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
    list(APPEND old -std=legacy)
    list(APPEND new -std=f2018)
  endif()
endif()

set(cglow_src src/glow.f90 src/cglow.f90 src/fieldm.f src/solzen.f90 src/ssflux.f90 src/rcolum.f90 src/qback.f90 src/etrans.f90 src/exsect.f src/gchem.f90 src/bands.f90 src/ephoto.f90 src/egrid.f90 src/maxt.f90)

set(snoem_src src/snoem.f90 src/snoemint.f90 src/geomag.f90)

set(utils_src src/mzgrid.f90 src/conduct.f90 src/nrlmsise00.f src/iri90.f)

add_library(cglow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(cglow PRIVATE ${old})

# ------  Python Matlab command line driver -----------

add_executable(glow.bin src/glowpython.f90 src/utils.f90 src/fsutils.f90)
target_link_libraries(glow.bin cglow)
target_compile_options(glow.bin PRIVATE ${new})

# ------ MPI driver ------------
find_package(MPI COMPONENTS Fortran)
find_package(NetCDF)
if(MPI_Fortran_FOUND AND NetCDF_FOUND)
  add_executable(mpi_glow.bin src/glowdriver.f90 src/readtgcm.f90 src/output.f90 src/tzgrid.f90 src/fsutils.f90)
  target_link_libraries(mpi_glow.bin cglow MPI::MPI_Fortran NetCDF::NetCDF_Fortran)
  target_compile_options(mpi_glow.bin PRIVATE ${new})
endif()

#-------- tests --------------

function(check_octave_source_runs code)

# imported target doesn't work with CMake 3.13
execute_process(COMMAND ${Octave_EXECUTABLE} --eval ${code}
  ERROR_QUIET OUTPUT_QUIET
  RESULT_VARIABLE ok
  TIMEOUT 5)

set(OctaveOK ${ok} CACHE BOOL "GNU Octave is sufficiently new to run self-tests")

endfunction(check_octave_source_runs)

find_package(Octave COMPONENTS Interpreter)
check_octave_source_runs("exit(exist('validateattributes'))")
if(OctaveOK)

add_test(NAME Simple COMMAND Octave::Interpreter --eval Simple
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/matlab)
set_tests_properties(Simple PROPERTIES TIMEOUT 20)

endif()
