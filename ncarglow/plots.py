from matplotlib.pyplot import figure
import xarray


def precip(precip: xarray.DataArray):
    ax = figure().gca()
    ax.plot(precip['energy'], precip)
    ax.set_xlabel('Energy bin centers [eV]')
    ax.set_ylabel('hemispherical flux [cm$^{-2}$ s$^{-1}$ eV$^{-1}$]')
    ax.grid(True)


def ver(iono: xarray.Dataset):
    _ver_group(iono['ver'].loc[:, ['4278', '5577', '6300', '5200']], 'Visible')


def _ver_group(iono: xarray.Dataset, ttxt: str):
    ax = figure().gca()
    for w in iono.wavelength:
        ax.plot(iono.loc[:, w], iono.alt_km, label=w.item())
    ax.set_xscale('log')
    ax.set_xlabel('Volume Emission Rate [Rayleigh]')
    ax.set_ylabel('altitude [km]')
    ax.set_title('Visible emissions')
    ax.set_ylim((50, None))
    ax.grid(True)
    ax.legend()
