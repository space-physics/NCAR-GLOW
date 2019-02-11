function iono = glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar)

Nalt = 250;  % jmax in Fortran

validateattributes(glat, {'numeric'}, {'scalar'})
validateattributes(glon, {'numeric'}, {'scalar'})
validateattributes(f107, {'numeric'}, {'positive', 'scalar'})
validateattributes(f107a, {'numeric'}, {'positive', 'scalar'})
validateattributes(f107p, {'numeric'}, {'positive', 'scalar'})
validateattributes(Ap, {'numeric'}, {'positive', 'scalar'})
validateattributes(Q, {'numeric'}, {'positive', 'scalar'})
validateattributes(Echar, {'numeric'}, {'positive', 'scalar'})
%% binary
cwd = fileparts(mfilename('fullpath'));
exe = [cwd,filesep,'..', filesep, 'build', filesep, 'glow.bin'];
if ispc, exe = [exe,'.exe']; end
assert(exist(exe,'file')==2, 'compile Glow via setup_glow.m')
%% time
tvec = datevec(time);
idate = [int2str(tvec(1)), int2str(date2doy(time))];
utsec = num2str(tvec(4)*3600 + tvec(5)*60 + tvec(6));

cmd = [exe, ' ', idate,' ',utsec,...
       ' ',num2str([glat, glon, f107a, f107, f107p, Ap, Q, Echar])];
[status,dat] = system(cmd);
if status ~= 0, error(dat), end

arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt, ...
  'ReturnOnError', false, 'HeaderLines', 2));

iono.altkm = arr(:,1);
iono.Tn = arr(:,2);
iono.O = arr(:,3);
iono.N2 = arr(:,4);
iono.NO = arr(:,5);
iono.NeIn = arr(:,6);
iono.NeOut = arr(:,7);
iono.ionrate = arr(:,8);
iono.Oplus = arr(:,9);
iono.O2plus = arr(:,10);
iono.NOplus = arr(:,11);
iono.N2D = arr(:,12);
iono.pederson = arr(:,13);
iono.hall = arr(:,14);
%% optical emissions (Rayleighs)
arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', Nalt, ...
  'ReturnOnError', false, 'HeaderLines',Nalt+3));

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

%% energy grid (eV)
Nbins = cell2mat(textscan(dat, '%d',1, 'HeaderLines',Nalt+3+Nalt));
iono.energy_bin_centers = cell2mat(textscan(dat, '%f',Nbins, 'HeaderLines',Nalt+3+Nalt+1));

iono.Eflux = cell2mat(textscan(dat, '%f',Nbins, 'HeaderLines',Nalt+3+Nalt+1+Nbins));
end
