project('GLOW', 'fortran',
  version : '0.981',
  meson_version : '>= 0.50',
  default_options : ['default_library=static', 'buildtype=release'])

fc = meson.get_compiler('fortran')
fargs_old = []
fargs_new = []
if fc.get_id() == 'gcc'
  if fc.version().version_compare('>=8')
    fargs_old = ['-w', '-std=legacy']
    fargs_new += '-std=f2018'
  else
    fargs_old += '-w'
  endif
elif fc.get_id() == 'intel'
  fargs_old += '-w'
  fargs_new = ['-stand f18', '-implicitnone', '-W1']
elif fc.get_id() == 'intel-cl'
  fargs_old += '/w'
  fargs_new = ['/stand:f18', '/4Yd', '/W1']
elif fc.get_id() == 'pgi'
  fargs_old += '-w'
  fargs_new +=  '-Mdclchk'
endif

mpi = dependency('mpi', language : 'fortran', required : false)
netcdf = dependency('netcdf', required : false)

subdir('src')

# Octave and Matlab tests can be squirrely, make user request to test them.
if not get_option('testmatlab')
  subdir_done()
endif

matlab = find_program('matlab', required : false)
octave = find_program('octave', required : false)
if octave.found()
  matoct = matlab
  margs = '-batch'
elif matlab.found()
  matoct = octave
  margs = '--eval'
endif

if octave.found() or matlab.found()
test('Simple', matoct, args : [margs, 'Simple'],
  workdir : meson.source_root() / 'matlab',
  timeout: 60)
endif
