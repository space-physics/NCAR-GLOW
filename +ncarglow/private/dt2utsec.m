function [idate, utsec] = dt2utsec(t)
arguments
  t (1,1) datetime
end

idate = [int2str(year(t)), int2str(day(t, 'dayofyear'))];
utsec = num2str(second(t, "secondofday"));

end
