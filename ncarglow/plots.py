from matplotlib.pyplot import figure
import xarray


def precip(precip: xarray.Dataset):
    ax = figure().gca()
    ax.plot(precip['Energy'], precip['Eflux'])
    ax.set_xlabel('Energy bin centers [eV]')
    ax.set_ylabel('hemispherical flux [cm$^{-2}$ s$^{-1}$ eV$^{-1}$]')
    ax.grid(True)


def ver(iono: xarray.Dataset):
    ax = figure().gca()
    ax.plot(iono['A4278'], iono['alt_km'])
    ax.set_xscale('log')
    ax.set_xlabel('Volume Emission Rate [Rayleigh]')
    ax.set_ylabel('altitude [km]')
    ax.set_ylim((50, None))
    ax.grid(True)
