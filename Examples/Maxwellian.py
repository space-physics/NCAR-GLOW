#!/usr/bin/env python
"""
Maxwellian shaped particle precipitation differential number flux
"""
import ncarglow as glow
import ncarglow.plots as plot
from datetime import datetime
from matplotlib.pyplot import show


time = datetime(2015, 12, 13, 10, 0, 0)
glat = 65.1
glon = -147.5
# %% flux [erg cm-2 s-1 == mW m-2 s-1]
Q = 1
# %% characteristic energy [eV]
Echar = 100e3
# %% Number of energy bins
Nbins = 250

iono = glow.maxwellian(time, glat, glon, Q, Echar, Nbins)
# %% plots
plot.precip(iono["precip"])
plot.ver(iono)
plot.density(iono)
plot.temperature(iono)

show()
