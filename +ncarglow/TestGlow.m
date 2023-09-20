classdef TestGlow < matlab.unittest.TestCase

methods(TestMethodSetup)

function add_path(tc) %#ok<MANU>
addpath(fullfile(fileparts(mfilename('fullpath')), '../..'))
end

end

methods(Test)

function basic(tc)

time = datetime(2015,12,13,10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 7;
f107 = 118.7;
f107a = 106.2;
f107p = 113.1;
Q = 1;
Echar = 100e3;
Nbins = 250;


iono = ncarglow.glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar, Nbins);

i = 32+1;

tc.assertEqual(iono.altkm(i), 101.8, "absTol", 0.1)
tc.verifyEqual(iono.Tn(i), 188., "absTol", 0.01)
tc.verifyEqual(iono.A5577(i), 20.54, "absTol", 0.0001)
tc.verifyEqual(iono.ionrate(i), 329., "absTol", 0.01)
tc.verifyEqual(iono.hall(i), 6.92e-5, "absTol", 1e-7)

end


function mono(tc)

time = datetime(2015,12,13, 10,0,0);
glat = 65.1;
glon = -147.5;
Ap = 4;
%% solar radio flux [10-22 W m-2]
f107 = 100;
f107a = 100;
f107p = 100;
%% Energy grid
Emin = 0.1;
Emax = 1e6;
E0 = 100e3;
Nbins = 250;

Ebins = ncarglow.loggrid(Emin, Emax, Nbins);
Phitop = ncarglow.monoenergetic_flux(Ebins, E0);
Phitop = Phitop * 3000;
%Phitop(:)=0;
%% glow model
% Axxxx wavelength in angstrom, intensity in photons cm-3 s-1
% density cgs cm-3
iono = ncarglow.glowenergy(time, glat, glon, f107a, f107, f107p, Ap, Ebins, Phitop);

i = 32+1;

tc.assertEqual(iono.altkm(i), 101.8, "absTol", 0.1)
tc.verifyEqual(iono.Tn(i), 189., "absTol", 0.01)
tc.verifyEqual(iono.A5577(i), 133.49, "absTol", 0.0001)
tc.verifyEqual(iono.ionrate(i), 1990., "absTol", 0.01)
tc.verifyEqual(iono.hall(i), 0.00018, "absTol", 1e-7)

end

end
end
