function plotglow(iono, times, glat, glon)

validateattributes(iono, {'struct'}, {'scalar'})
validateattributes(glat, {'numeric'}, {'finite'})
validateattributes(glon, {'numeric'}, {'finite'})
%% Density profiles
hp = figure;
ax = axes('parent', hp, 'nextplot', 'add');
%try
%sgtitle(hp, {[datestr(times),' deg.  (',num2str(glat),', ', num2str(glon),')']})
%end

semilogx(ax, iono.O, iono.altkm, 'DisplayName', 'O')
semilogx(ax, iono.N2, iono.altkm, 'DisplayName', 'N_2')
semilogx(ax, iono.NO, iono.altkm, 'DisplayName', 'NO')
semilogx(ax, iono.Oplus, iono.altkm, 'DisplayName', 'NO^+')
semilogx(ax, iono.O2plus, iono.altkm, 'DisplayName', 'NO_2^+')
semilogx(ax, iono.N2D, iono.altkm, 'DisplayName', 'N_2(D)')

title(ax, 'Number Densities')
xlabel(ax, 'Density [cm^-3]')
ylabel(ax, 'altitude [km]')
xlim(ax, [1e4,1e16])

set(ax,'xscale','log')
grid(ax, 'on')
legend(ax, 'show','location','northeast')

%% Temperature Profiles

h=figure;
ax = axes('parent',h);
set(ax, 'nextplot','add')

plot(ax, iono.Tn, iono.altkm, 'DisplayName', 'T_n')

title('Temperature')
xlabel(ax, 'Temperature [K]')
ylabel(ax, 'altitude [km]')

grid(ax, 'on')
legend(ax, 'show','location','northeast')
%% particle flux
ttxt = 'Particle Flux';
hf=figure('Name', ttxt);
ax = axes('parent', hf);
semilogx(ax, iono.energy_bin_centers, iono.Eflux)
grid(ax, 'on')
title(ax, ttxt)
xlabel(ax, 'energy bin centers [eV]')
ylabel(ax, 'hemispherical flux [cm^{-2} s^{-1} eV^{-1}')
%% optical emissions
ttxt = 'Optical Emissions';
ho = figure('Name', ttxt);
ax = axes('parent', ho, 'nextplot', 'add');
semilogx(ax, iono.A3371, iono.altkm, 'displayname', '3371')
semilogx(ax, iono.A4278, iono.altkm, 'displayname', '4278')
semilogx(ax, iono.A5200, iono.altkm, 'displayname', '5200')
semilogx(ax, iono.A5577, iono.altkm, 'displayname', '5577')
semilogx(ax, iono.A6300, iono.altkm, 'displayname', '6300')
semilogx(ax, iono.A7320, iono.altkm, 'displayname', '7320')
semilogx(ax, iono.A10400, iono.altkm, 'displayname', '10400')
semilogx(ax, iono.A3644, iono.altkm, 'displayname', '3644')
semilogx(ax, iono.A7774, iono.altkm, 'displayname', '7774')
semilogx(ax, iono.A8446, iono.altkm, 'displayname', '8446')
semilogx(ax, iono.A3726, iono.altkm, 'displayname', '3726')
semilogx(ax, iono.LBH, iono.altkm, 'displayname', 'LBH')
semilogx(ax, iono.A1356, iono.altkm, 'displayname', '1356')
semilogx(ax, iono.A1493, iono.altkm, 'displayname', '1493')
semilogx(ax, iono.A1304, iono.altkm, 'displayname', '1304')
set(ax, 'xscale', 'log')
grid(ax,'on')
title(ax, ttxt)
legend(ax, 'show')
end