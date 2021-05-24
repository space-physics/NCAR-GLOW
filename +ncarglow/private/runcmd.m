function runcmd(cmd)
arguments
  cmd (1,1) string
end

[status, ret] = system(cmd);

assert(status == 0, ret)

disp(ret)

end
