function meson(srcdir, bindir)
arguments
  srcdir (1,1) string {mustBeFolder}
  bindir (1,1) string
end

cmd = "meson setup " + bindir + " " + srcdir;
if isfile(fullfile(bindir, 'build.ninja'))
  cmd = cmd + " --wipe";
end


runcmd(cmd)

runcmd("meson compile -C " + bindir)

end
