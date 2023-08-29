function exe = exepath(exename)
arguments
  exename (1,1) string
end

if ispc, exename = exename + ".exe"; end

cwd = fileparts(mfilename('fullpath'));
src = fullfile(cwd, "../../src/ncarglow");
bindir = fullfile(src, "build");
exe = fullfile(bindir, exename);

if ~isfile(exe)
 build(src, bindir)
end

end
