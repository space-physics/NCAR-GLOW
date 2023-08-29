function runcmd(cmd)
arguments
  cmd (1,1) string
end

[status, ret] = system(cmd);

disp(ret)

assert(status == 0, ret)

end
