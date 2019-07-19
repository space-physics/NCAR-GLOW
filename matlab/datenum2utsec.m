function [idate, utsec] = datenum2utsec(time)

validateattributes(time, {'numeric'}, {'scalar', 'positive'});

tvec = datevec(time);
idate = [int2str(tvec(1)), int2str(date2doy(time))];
utsec = num2str(tvec(4)*3600 + tvec(5)*60 + tvec(6));

end