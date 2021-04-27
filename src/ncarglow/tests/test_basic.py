#!/usr/bin/env python
import ncarglow as glow
import pytest
from pytest import approx
from datetime import datetime
import numpy as np


def test_maxwellian():
    time = datetime(2015, 12, 13, 10, 0, 0)
    glat = 65.1
    glon = -147.5
    # %% flux [erg cm-2 s-1 == mW m-2 s-1]
    Q = 1.0
    # %% characteristic energy [eV]
    Echar = 100e3
    # %% Number of energy bins
    Nbins = 250

    try:
        iono = glow.maxwellian(time, glat, glon, Q, Echar, Nbins)
    except ConnectionError:
        pytest.skip("CI internet FTP issue")

    assert iono["alt_km"].size == Nbins
    i = 32
    assert iono.alt_km[i] == approx(101.8)
    assert iono["Tn"][i] == approx(188.0)
    assert iono["ver"].loc[:, "5577"][i] == approx(20.45)
    assert iono["ionrate"][i] == approx(335.0)
    assert iono["hall"][i].item() == approx(6.98e-05)


def test_noprecip():
    time = datetime(2015, 12, 13, 10, 0, 0)
    glat = 65.1
    glon = -147.5
    N_energy_bins = 250

    try:
        iono = glow.no_precipitation(time, glat, glon, N_energy_bins)
    except ConnectionError:
        pytest.skip("CI internet FTP issue")

    assert iono["alt_km"].size == N_energy_bins
    i = 32
    assert iono.alt_km[i] == approx(101.8)
    assert iono["Tn"][i] == approx(188.0)
    assert iono["ver"].loc[:, "5577"][i] == approx(0.0)
    assert iono["ver"].loc[:, "5577"][70] == approx(0.09)
    assert iono["ionrate"][i] == approx(8.35)
    assert iono["hall"][i].item() == approx(1.08e-05)


def test_ebins():
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
    try:
        iono = glow.ebins(time, glat, glon, Ebins, Phitop)
    except ConnectionError:
        pytest.skip("CI internet FTP issue")

    assert iono["alt_km"].size == Nbins
    assert iono["Tn"][32] == approx(188.0)
    assert iono["ver"].loc[:, "5577"][32] == approx(0.04)


if __name__ == "__main__":
    pytest.main([__file__])
