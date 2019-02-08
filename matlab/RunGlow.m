time = datenum(2015,12,13,10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 4;
f107 = 100;
f107a = 100;
f107p = 100;
Q = 1;
Echar = 100e3;

iono = glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar);

plotiono(iono, time, glat, glon)