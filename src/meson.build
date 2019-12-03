
cglow_src = files('glow.f90', 'cglow.f90', 'fieldm.f', 'solzen.f90', 'ssflux.f90', 'rcolum.f90', 'qback.f90', 'etrans.f90', 'exsect.f', 'gchem.f90', 'bands.f90', 'ephoto.f90', 'egrid.f90', 'maxt.f90')
snoem_src = files('snoem.f90', 'snoemint.f90', 'geomag.f90')
utils_src = files('mzgrid.f90', 'conduct.f90', 'nrlmsise00.f', 'iri90.f')
glowdriver_src = files('glowpython.f90', 'utils.f90', 'fsutils.f90')

cglow = library('cglow',
  sources: [cglow_src, snoem_src, utils_src],
  fortran_args : fargs_old)

if meson.is_subproject()
  subdir_done()
endif

# --- Stan's MPI/NetCDF driver

mpi = dependency('mpi', language : 'fortran', required : false, disabler: true)
netcdf = dependency('netcdf', required : false, disabler: true)

mpiglow = executable('mpi_glow.bin',
  sources: ['glowdriver.f90', 'readtgcm.f90', 'output.f90', 'tzgrid.f90','fsutils.f90'],
  dependencies : [netcdf, mpi],
  link_with : cglow,
  fortran_args : fargs_old)
