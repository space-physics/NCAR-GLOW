%% simple
time = datenum(2015,12,13,10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 7;
f107 = 118.7;
f107a = 78.7;
f107p = 113.1;
Q = 1;
Echar = 100e3;
Nbins = 250;

cwd = fileparts(mfilename('fullpath'));
addpath([cwd, filesep, '..', filesep, 'matlab'])

iono = glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar, Nbins);

i = 32+1;

assert(abs(iono.altkm(i)  -  101.8) < 0.1, ['alt_km: expected 101.8, but got: ', num2str(iono.altkm(i))])
assert(abs(iono.Tn(i)  - 188.) < 0.01, ['Tn: expected 188., but got: ', num2str(iono.Tn(i))])
assert(abs(iono.A5577(i) - 20.45) < 0.0001,   ['A5577: expected 20.45, but got: ', num2str(iono.A5577(i))])
assert(abs(iono.ionrate(i) - 335.) < 0.01, ['ionrate: expected 335. but got: ', num2str(iono.ionrate(i))])
assert(abs(iono.hall(i) - 6.98e-5) < 1e-7, ['hall: expected 6.98e-5 but got: ', num2str(iono.hall(i))])
