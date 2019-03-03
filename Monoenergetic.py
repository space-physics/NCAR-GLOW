#!/usr/bin/env python
import ncarglow as glow
from datetime import datetime
import ncarglow.plots as gp
import numpy as np
from matplotlib.pyplot import show
import tempfile


time = datetime(2015, 12, 13, 10, 0, 0)
glat = 65.1
glon = -147.5
Ap = 4
# %% solar radio flux [10-22 W m-2]
f107 = 100
f107a = 100
f107p = 100
# %% Energy grid [eV]
Emin = 0.1
Emax = 1e6
E0 = 100e3
Nbins = 250
# %% monoenergetic beam
Ebins = np.logspace(np.log10(Emin), np.log10(Emax), Nbins).astype(np.float32)
Phitop = np.zeros_like(Ebins)
Phitop[abs(Ebins-E0).argmin()] = 1.
Phitop = Phitop.astype(np.float32)
# %% Matlab compatible workaround (may change to use stdin in future)
with tempfile.NamedTemporaryFile('wb') as f:
    Ebins.tofile(f)
    Phitop.tofile(f)
# %% run glow
    iono, precip, production, loss = glow.ebins(time, glat, glon, f107a, f107, f107p, Ap,
                                                Ebins, Phitop, f.name)

# %% simple plots
gp.precip(precip)

gp.ver(iono)

show()
