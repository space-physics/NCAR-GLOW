function setup(build_sys, srcdir, builddir)

if nargin<1
  build_sys = 'meson';
end
validateattributes(build_sys, {'char'}, {'vector'})

if nargin < 3
cwd = fileparts(mfilename('fullpath'));
srcdir =   [cwd, filesep,'..'];
builddir = [cwd, filesep,'..',filesep,'build'];
end

assert(exist(srcdir,'dir')==7, ['source directory ',srcdir,' does not exist'])
assert(exist(builddir,'dir')==7, ['build directory ',builddir,' does not exist'])

switch build_sys
  case 'meson', setup_meson(srcdir, builddir)
  case 'cmake', setup_cmake(srcdir, builddir)
end

end