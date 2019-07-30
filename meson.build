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
elif fc.get_id() == 'flang'
  fargs_old += '-w'
endif

subdir('src')

# Octave and Matlab tests can be squirrely, make user request to test them.
if meson.is_subproject() or not get_option('testmatlab')
  subdir_done()
endif

margs = {'matlab': '-batch', 'octave': '--eval'}

foreach m : ['matlab', 'octave']

  mexe = find_program(m, required : false)
  if not mexe.found()
    continue
  endif

  test('Simple-' + m, mexe,
    args : [margs[m], 'Simple'],
    workdir : meson.current_source_dir() / 'matlab',
    timeout: 60)

endforeach
