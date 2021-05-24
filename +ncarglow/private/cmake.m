function cmake(srcdir, bindir)
arguments
  srcdir (1,1) string
  bindir (1,1) string
end

tail = " -S" + srcdir + " -B" + bindir;

if ispc && isempty(getenv("CMAKE_GENERATOR"))
  setenv("CMAKE_GENERATOR", "MinGW Makefiles")
end

runcmd("cmake " + tail)

runcmd("cmake --build " + bindir + " --parallel")

end
