#!/usr/bin/env python
"""
no particle precipitation.
May give non-physical results, for testing only.
"""
import ncarglow as glow
import ncarglow.plots as plot
from datetime import datetime
from matplotlib.pyplot import show


time = datetime(2015, 12, 13, 10, 0, 0)
glat = 65.1
glon = -147.5
# %% Number of energy bins
Nbins = 250
Talt = 400.0  # [km]
Thot = 4000  # [K}]

iono = glow.no_source(time, glat, glon, Nbins, Talt=Talt, Thot=Thot)
# %% simple plots
# plot.precip(iono["precip"])
plot.temperature(iono)

plot.ver(iono)

show()
