#!/usr/bin/env python
"""
no particle precipitation
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

iono = glow.no_precipitation(time, glat, glon, Nbins)
# %% simple plots
plot.precip(iono["precip"])

plot.ver(iono)

show()
