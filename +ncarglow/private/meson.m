function meson(srcdir, bindir)
arguments
  srcdir (1,1) string
  bindir (1,1) string
end

cmd = ['meson setup ',bindir,' ',srcdir];
if is_file([bindir, '/build.ninja'])
  cmd = [cmd, ' --wipe'];
end


runcmd(cmd)

runcmd(['meson test -C' ,bindir])

end
