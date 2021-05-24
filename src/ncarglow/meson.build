project('GLOW', 'fortran',
  version : '0.981',
  meson_version : '>= 0.51.2',
  default_options : ['default_library=static', 'buildtype=release', 'warning_level=0', 'fortran_std=legacy'])

fc = meson.get_compiler('fortran')
fargs_old = [fc.first_supported_argument(['-w', '-nowarn', '/nowarn']),
            fc.first_supported_argument(['-std=legacy', '-nostand', '/nostand'])]

subdir('fortran')

cglow = library('cglow',
  sources: [cglow_src, snoem_src, utils_src],
  fortran_args : fargs_old,
  install: true)

# -- optional MPI glow driver
if get_option('mpiglow').enabled()
  netcdf = dependencies('netcdf')
  mpi = dependencies('mpi')

  mpiglow_bin = executable('mpi_glow.bin',
    sources: mpiglow_src,
    dependencies : [netcdf, mpi],
    link_with : cglow,
    fortran_args : fargs_old)
endif

# ------  Python Matlab command line driver -----------

glowexe = executable('glow.bin', glowdriver_src,
  link_with : cglow,
  install: true)

foreach k, v : {'matlab': '-batch', 'octave': '--eval'}

  mexe = find_program(k, required : get_option('matlab'), disabler: true)

  test('Simple-' + k, mexe,
    args : [v, 'Simple'],
    workdir : meson.current_source_dir() / 'matlab',
    timeout: 60)

endforeach
