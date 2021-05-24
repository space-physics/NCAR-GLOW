function build(srcdir, builddir, build_sys)
arguments
  srcdir (1,1) string = fullfile(fileparts(mfilename('fullpath')), "../../src/ncarglow")
  builddir (1,1) string = fullfile(srcdir, "build")
  build_sys string {mustBeScalarOrEmpty} = string.empty
end

assert(isfile(fullfile(srcdir, "CMakeLists.txt")), "source directory not found: %s", srcdir)

if isempty(build_sys)
  if system('meson --version') == 0 && system('ninja --version') == 0
    build_sys = 'meson';
  elseif system('cmake --version') == 0
    build_sys = 'cmake';
  else
    error('could not find Meson + Ninja or CMake')
  end
end

switch build_sys
  case 'meson', meson(srcdir, builddir)
  case 'cmake', cmake(srcdir, builddir)
  otherwise, error('unknown build system %s', build_sys)
end

end % function
