function exe = exepath(exename)
arguments
  exename (1,1) string
end

if ispc, exename = exename + ".exe"; end

cwd = fileparts(mfilename('fullpath'));
exe = fullfile(cwd, '../../src/ncarglow/build', exename);

if ~isfile(exe)
 build()
end

end
