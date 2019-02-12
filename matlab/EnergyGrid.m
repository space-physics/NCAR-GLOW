time = datenum(2015,12,13,10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 4;
%% solar radio flux [10-22 W m-2]
f107 = 100;
f107a = 100;
f107p = 100;
%% Energy grid
Emin = 10;
Emax = 1e6;
E0 = 100e3;
Nbins = 250;

[Ebins, Phitop] = monoenergetic(Emin, Emax, Nbins, E0);

%% glow model
% Axxxx wavelength in angstrom, intensity in Rayleigh 10^6 photons cm-2
% density cgs cm-3
iono = glowenergy(time, glat, glon, f107a, f107, f107p, Ap, Ebins, Phitop);

plotglow(iono, time, glat, glon)
