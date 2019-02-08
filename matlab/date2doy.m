function doy = date2doy(adate)

v = datevec(adate);
n = datenum(v);

doy = n - datenum(v(:,1), 1,0);

end
