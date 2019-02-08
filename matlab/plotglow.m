function plotglow(iono, times, glat, glon)

validateattributes(iono, {'struct'}, {'scalar'})
validateattributes(glat, {'numeric'}, {'finite'})
validateattributes(glon, {'numeric'}, {'finite'})
%% Density profiles
hp = figure;
try
sgtitle(hp, {[datestr(times),' deg.  (',num2str(glat),', ', num2str(glon),')']})
end
ax = subplot(1,2,1, 'parent', hp);
set(ax, 'nextplot','add')

semilogx(ax, iono.O, iono.altkm, 'DisplayName', 'O')
semilogx(ax, iono.N2, iono.altkm, 'DisplayName', 'N_2')
semilogx(ax, iono.NO, iono.altkm, 'DisplayName', 'NO')
semilogx(ax, iono.Oplus, iono.altkm, 'DisplayName', 'NO^+')
semilogx(ax, iono.O2plus, iono.altkm, 'DisplayName', 'NO_2^+')
semilogx(ax, iono.N2D, iono.altkm, 'DisplayName', 'N_2(D)')

title(ax, 'Number Densities')
xlabel(ax, 'Density [cm^-3]')
ylabel(ax, 'altitude [km]')
xlim(ax, [1e4,1e12])

set(ax,'xscale','log')
grid(ax, 'on')
legend(ax, 'show','location','northeast')

%% Temperature Profiles

ax = subplot(1,2,2, 'parent', hp);
set(ax, 'nextplot','add')

plot(ax, iono.Tn, iono.altkm, 'DisplayName', 'T_n')

title('Temperature')
xlabel(ax, 'Temperature [K]')
ylabel(ax, 'altitude [km]')

grid(ax, 'on')
legend(ax, 'show','location','northeast')

end