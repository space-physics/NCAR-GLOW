%% setup GLOW using CMake+Fortran compiler

if ispc
  ccmd = 'cmake -G "MinGW Makefiles" -DCMAKE_SH="CMAKE_SH-NOTFOUND" -S .. -B build';
else
  ccmd = 'cmake -S .. -B build';
end

[status, ret] = system(ccmd);
if status~=0, error(ret), end
disp(ret)

[status, ret] = system('cmake --build build -j');
if status~=0, error(ret), end
disp(ret)

disp('Fortran compilation complete')
