set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)

set(snoem_src snoem.f90 snoemint.f90 geomag.f90)

set(utils_src mzgrid.f90 conduct.f90 nrlmsise00.f iri90.f)

target_sources(cglow PRIVATE ${cglow_src} ${snoem_src} ${utils_src})

target_sources(glow.bin PRIVATE glowpython.f90 utils.f90 fsutils.f90)

# ------ MPI driver ------------
if(mpiglow)
  find_package(MPI COMPONENTS Fortran)
  find_package(NetCDF)
  if(MPI_Fortran_FOUND AND NetCDF_FOUND)
    add_executable(mpi_glow.bin glowdriver.f90 readtgcm.f90 output.f90 tzgrid.f90 fsutils.f90)
    target_include_directories(mpi_glow.bin PRIVATE ${NetCDF_INCLUDE_DIRS})
    target_link_libraries(mpi_glow.bin cglow MPI::MPI_Fortran ${NetCDF_LIBRARIES})
    target_compile_options(mpi_glow.bin PRIVATE ${new})
    set_target_properties(mpi_glow.bin PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
  endif()
endif(mpiglow)
#-------- tests --------------

if(matlab)
# ------  Matlab command line driver -----------
  find_package(Matlab COMPONENTS MAIN_PROGRAM)
  if(Matlab_FOUND)
    add_test(NAME SimpleMatlab COMMAND ${Matlab_MAIN_PROGRAM} -batch Simple
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/matlab)
    set_tests_properties(SimpleMatlab PROPERTIES TIMEOUT 90)
  endif()
endif(matlab)
