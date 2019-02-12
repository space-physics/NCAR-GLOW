function exe = glowpath()

cwd = fileparts(mfilename('fullpath'));
exe = [cwd,filesep,'..', filesep, 'build', filesep, 'glow.bin'];
if ispc, exe = [exe,'.exe']; end
assert(exist(exe,'file')==2, 'compile Glow via setup_glow.m')

end