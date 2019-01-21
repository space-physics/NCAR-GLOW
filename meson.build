project('GLOW', 'fortran', 
  version : '0.981',
  default_options : ['default_library=static'])

cglow = library('cglow', 'glow.f90', 'cglow.f90', 'fieldm.f', 'solzen.f90', 'ssflux.f90', 'rcolum.f90', 'qback.f90', 'etrans.f90', 'exsect.f', 'gchem.f90', 'bands.f90', 'ephoto.f90', 'egrid.f90', 'maxt.f90',
  fortran_args : '-w')
