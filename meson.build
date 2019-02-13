project('GLOW', 'fortran',
  version : '0.981',
  default_options : ['default_library=static', 'buildtype=release'])

add_global_arguments('-g', language : 'fortran')
old = ['-w']
new = ['-Wextra','-Wpedantic']
fc = meson.get_compiler('fortran')
if fc.version().version_compare('>=8')
  old += '-std=legacy'
  new += '-std=f2018'
endif

subdir('src')

cglow = library('cglow', cglow_src, snoem_src, utils_src, fortran_args : old)

# ------  Python Matlab command line driver -----------

glowexe = executable('glow.bin',
  'src/glowpython.f90', 'src/utils.f90', 'src/fsutils.f90',
  link_with : cglow,
  fortran_args : new)

octave = find_program('octave', required : false)
if octave.found()
  test('Simple', octave, args : ['--eval', 'Simple'],
    workdir : meson.source_root() / 'matlab')
endif
 # ------ MPI driver ------------
mpi = dependency('mpi', language : 'fortran')
netcdf = dependency('NetCDF',
  method : 'cmake', cmake_module_path : meson.source_root() / 'cmake/Modules',
  required : false)
if mpi.found() and netcdf.found()
mpiglow = executable('mpi_glow.bin',
  'src/glowdriver.f90', 'src/readtgcm.f90', 'src/output.f90', 'src/tzgrid.f90','src/fsutils.f90',
  dependencies : [netcdf, mpi],
  link_with : cglow,
  fortran_args : old)
endif
