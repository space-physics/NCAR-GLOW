%% setup GLOW using CMake+Fortran compiler

system('cmake --version')

cwd = fileparts(mfilename('fullpath'));

srcdir =   [cwd, filesep,'..'];
builddir = [cwd, filesep,'..',filesep,'build'];
tail = [' -S ', srcdir, ' -B ', builddir];

if ispc
  ccmd = ['cmake -G "MinGW Makefiles" -DCMAKE_SH="CMAKE_SH-NOTFOUND" ', tail];
else
  ccmd = ['cmake ',tail];
end

[status, ret] = system(ccmd);
if status~=0, error(ret), end
disp(ret)

[status, ret] = system(['cmake --build ',builddir,' -j']);
if status~=0, error(ret), end
disp(ret)

disp('Fortran compilation complete')
