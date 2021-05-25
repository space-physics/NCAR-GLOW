function iono = glowparse(dat)
arguments
  dat (1,1) string
end

Nalt = 250;  % jmax in Fortran

irow = 2;
if ispc; irow=4; end

arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt, ...
  'ReturnOnError', false, 'HeaderLines', irow));

iono.altkm = arr(:,1);
iono.Tn = arr(:,2);
iono.O = arr(:,3);
iono.N2 = arr(:,4);
iono.O2 = arr(:,5);
iono.NO = arr(:,6);
iono.NeIn = arr(:,7);
iono.NeOut = arr(:,8);
iono.ionrate = arr(:,9);
iono.Oplus = arr(:,10);
iono.O2plus = arr(:,11);
iono.NOplus = arr(:,12);
iono.N2D = arr(:,13);
iono.pederson = arr(:,14);
iono.hall = arr(:,15);

irow = irow + Nalt + 1;
%% optical emissions (Rayleighs)
arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt, ...
  'ReturnOnError', false, 'HeaderLines', irow));

assert(all(abs(iono.altkm-arr(:,1))) < 1e-3, 'altitude grid not matching')

iono.A3371 = arr(:,2);
iono.A4278 = arr(:,3);
iono.A5200 = arr(:,4);
iono.A5577 = arr(:,5);
iono.A6300 = arr(:,6);
iono.A7320 = arr(:,7);
iono.A10400 = arr(:,8);
iono.A3644 = arr(:,9);
iono.A7774 = arr(:,10);
iono.A8446 = arr(:,11);
iono.A3726 = arr(:,12);
iono.LBH = arr(:,13);
iono.A1356 = arr(:,14);
iono.A1493 = arr(:,15);
iono.A1304 = arr(:,16);

irow = irow + Nalt;
%% Production & loss
iono.production = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt,...
  'ReturnOnError', false, 'HeaderLines', irow));
irow = irow + Nalt;

iono.loss = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt,...
  'ReturnOnError', false, 'HeaderLines', irow));
irow = irow + Nalt;
assert(all(size(iono.loss)==[Nalt, 12+1]), 'Prod/loss: incorrect read of stdout from GLOW')
%% energy grid (eV)
Nbins = cell2mat(textscan(dat, '%d',1, 'HeaderLines',irow));
irow = irow + 1;
iono.energy_bin_centers = cell2mat(textscan(dat, '%f',Nbins, 'HeaderLines', irow));
irow = irow + 1;
iono.Eflux = cell2mat(textscan(dat, '%f',Nbins, 'HeaderLines', irow));
irow = irow + 1;
assert(length(iono.Eflux)==Nbins, 'energy: incorrect read of stdout from GLOW')
%% excited states
irow = irow + 1;
arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f',Nbins, 'HeaderLines', irow));
iono.excitedDensity = arr(:, 2:end);
iono.states = ["O+(2P)", "O+(2D)", "O+(4S)", "N+", "N2+", "O2+", "NO+", "N2(A)", "N(2P)", "N(2D)", "O(1S)", "O(1D)"];
irow = irow + 1;
assert(size(iono.excitedDensity, 1)==Nbins, 'states: incorrect read of stdout from GLOW')
assert(length(iono.states) == size(iono.excitedDensity,2), "states: incorrect read")
%% Te, Ti
irow = irow + Nalt;
arr = cell2mat(textscan(dat, '%f %f %f', Nbins, 'HeaderLines', irow));
assert(size(arr, 1)==Nbins, 'temperature: incorrect read of stdout from GLOW')
iono.Te = arr(:,2);
iono.Ti = arr(:,3);
end
