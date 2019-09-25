#!/usr/bin/env python
import ncarglow as glow
from datetime import datetime
import ncarglow.plots as plot
import numpy as np
from matplotlib.pyplot import show


time = datetime(2015, 12, 13, 10, 0, 0)
glat = 65.1
glon = -147.5
# %% Energy grid [eV]
Emin = 0.1
Emax = 1e6
E0 = 100e3
Nbins = 250
# %% monoenergetic beam
Ebins = np.logspace(np.log10(Emin), np.log10(Emax), Nbins).astype(np.float32)
Phitop = np.zeros_like(Ebins)
Phitop[abs(Ebins - E0).argmin()] = 1.0
Phitop = Phitop.astype(np.float32)
# %% run glow
iono = glow.ebins(time, glat, glon, Ebins, Phitop)
# %% simple plots
plot.precip(iono["precip"])

plot.ver(iono)

show()
