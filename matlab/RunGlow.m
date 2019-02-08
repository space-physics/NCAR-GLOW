time = datenum(2015,12,13,10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 4;
%% solar radio flux [10-22 W m-2]
f107 = 100;
f107a = 100;
f107p = 100;
%% Particle flux [erg cm-2 s-1 == mW m-2 s-1]
Q = 1;
%% characteristic energy [eV]
Echar = 100e3;

%% glow model
% Axxxx wavelength in angstrom, intensity in Rayleigh 10^6 photons cm-2
% density cgs cm-3
iono = glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar);

plotglow(iono, time, glat, glon)