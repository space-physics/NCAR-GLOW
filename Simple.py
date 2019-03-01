#!/usr/bin/env python
import ncarglow as glow
from datetime import datetime
from matplotlib.pyplot import figure, show


time = datetime(2015, 12, 13, 10, 0, 0)
glat = 65.1
glon = -147.5
Ap = 4
# %% solar radio flux [10-22 W m-2]
f107 = 100
f107a = 100
f107p = 100
# %% flux [erg cm-2 s-1 == mW m-2 s-1]
Q = 1
# %% characteristic energy [eV]
Echar = 100e3
# %% Number of energy bins
Nbins = 250

iono, precip, production, loss = glow.simple(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar, Nbins)

for k, v in iono.items():
    print(k)
    print(v)

# %% simple plots
ax = figure().gca()
ax.plot(precip['Energy'], precip['Eflux'])
ax.set_xlabel('Energy bin centers [eV]')
ax.set_ylabel('hemispherical flux')
ax.grid(True)

ax = figure().gca()
ax.plot(iono['A4278'], iono['alt_km'])
ax.set_xscale('log')
ax.set_xlabel('Volume Emission Rate [Rayleigh]')
ax.set_ylabel('altitude [km]')
ax.set_ylim((50, None))
ax.grid(True)

show()
