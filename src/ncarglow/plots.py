from matplotlib.pyplot import figure
import xarray
import numpy as np

__all__ = ["precip", "ver"]


def density(iono: xarray.Dataset):
    fig = figure()
    axs = fig.subplots(1, 2, sharey=True)

    fig.suptitle("Number Density")

    ax = axs[0]
    for v in ("O", "N2", "O2", "NO"):
        ax.plot(iono[v], iono[v].alt_km, label=v)
    ax.set_xscale("log")
    ax.set_ylabel("altitude [km]")
    ax.set_xlabel("Density [cm$^{-3}$]")
    ax.set_title("Neutrals")
    ax.grid(True)
    ax.set_xlim(1, None)
    ax.legend(loc="best")

    ax = axs[1]
    for v in ("O+", "O2+", "NO+", "N2D"):
        ax.plot(iono[v], iono[v].alt_km, label=v)
    ax.set_xscale("log")
    ax.set_title("Ions")
    ax.grid(True)
    ax.set_xlim(1, None)
    ax.legend(loc="best")


def precip(precip: xarray.DataArray):
    ax = figure().gca()
    ax.plot(precip["energy"] / 1e3, precip)
    ax.set_xlabel("Energy bin centers [keV]")
    ax.set_ylabel("hemispherical flux [cm$^{-2}$ s$^{-1}$ eV$^{-1}$]")
    ax.set_title("precipitation: differential number flux")
    ax.grid(True)


def temperature(iono: xarray.Dataset):
    time = iono.time
    location = iono.glatlon
    tail = f"\n{time} {location}"
    ax = figure().gca()
    ax.plot(iono["Ti"], iono["Ti"].alt_km, label="$T_i$")
    ax.plot(iono["Te"], iono["Te"].alt_km, label="$T_e$")
    ax.plot(iono["Tn"], iono["Tn"].alt_km, label="$T_n$")
    ax.set_xlabel("Temperature [K]")
    ax.set_ylabel("altitude [km]")
    ax.set_title("Ion, Electron, Neutral temperatures" + tail)
    ax.grid(True)
    ax.legend()


def altitude(iono: xarray.Dataset):
    ax = figure().gca()
    ax.plot(iono.alt_km)
    ax.set_xlabel("altitude grid index #")
    ax.set_ylabel("altitude [km]")
    ax.set_title("altitude grid cells")
    ax.grid(True)


def ver(iono: xarray.Dataset):
    time = iono.time
    location = iono.glatlon
    tail = f"\n{time} {location}"

    fig = figure(constrained_layout=True)
    axs = fig.subplots(1, 3, sharey=True)

    fig.suptitle(tail)
    ver_group(iono["ver"].loc[:, ["4278", "5577", "6300", "5200"]], "Visible", axs[0])
    ver_group(iono["ver"].loc[:, ["7320", "7774", "8446", "10400"]], "Infrared", axs[1])
    ver_group(
        iono["ver"].loc[:, ["3371", "3644", "3726", "1356", "1493", "1304", "LBH"]],
        "Ultraviolet",
        axs[2],
    )
    axs[0].set_ylabel("altitude [km]")
    axs[0].set_xlabel("Volume Emission Rate [Rayleigh]")


def ver_group(iono: xarray.DataArray, ttxt: str, ax):
    nm = np.nanmax(iono)
    if nm == 0 or np.isnan(nm):
        return

    colors = {
        "4278": "blue",
        "5577": "xkcd:dark lime green",
        "5200": "xkcd:golden yellow",
        "6300": "red",
    }

    for w in iono.wavelength:
        ax.plot(iono.loc[:, w], iono.alt_km, label=w.item(), color=colors.get(w.item()))
    ax.set_xscale("log")
    ax.set_ylim(90, 500)
    ax.set_title(ttxt)
    ax.grid(True)
    ax.legend()
