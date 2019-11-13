
cglow_src = files('glow.f90', 'cglow.f90', 'fieldm.f', 'solzen.f90', 'ssflux.f90', 'rcolum.f90', 'qback.f90', 'etrans.f90', 'exsect.f', 'gchem.f90', 'bands.f90', 'ephoto.f90', 'egrid.f90', 'maxt.f90')
snoem_src = files('snoem.f90', 'snoemint.f90', 'geomag.f90')
utils_src = files('mzgrid.f90', 'conduct.f90', 'nrlmsise00.f', 'iri90.f')

cglow = library('cglow', cglow_src, snoem_src, utils_src, fortran_args : fargs_old)

if meson.is_subproject()
  subdir_done()
endif

# ------  Python Matlab command line driver -----------
exe_name = 'glow.bin'
glowexe = executable(exe_name,
  'glowpython.f90', 'utils.f90', 'fsutils.f90',
  link_with : cglow,
  fortran_args : fargs_new)

# -- hack: an always dirty target to be like RUNTIME_OUTPUT_DIRECTORY on CMake
if host_machine.system() == 'windows'
  exe_name += '.exe'
endif

custom_target('glow_runtime_output_directory',
  build_by_default: true,
  output: 'dummy',
  command: ['python', '-c', 'import shutil; shutil.copy("' + meson.current_build_dir() / exe_name + '", "' + meson.current_build_dir() / '..' + '")'],
  depends: glowexe)
# -- end hack

mpi = dependency('mpi', language : 'fortran', required : false, disabler: true)
netcdf = dependency('netcdf', required : false, disabler: true)

mpiglow = executable('mpi_glow.bin',
  'glowdriver.f90', 'readtgcm.f90', 'output.f90', 'tzgrid.f90','fsutils.f90',
  dependencies : [netcdf, mpi],
  link_with : cglow,
  fortran_args : fargs_old)
