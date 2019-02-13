%% setup GLOW using Meson+Fortran compiler

[status, ret] = system('meson setup build ..');
if status~=0, error(ret), end
disp(ret)

[status, ret] = system('ninja -C build');
if status~=0, error(ret), end
disp(ret)

disp('Fortran compilation complete')
