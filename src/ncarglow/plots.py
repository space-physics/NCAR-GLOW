from matplotlib.pyplot import figure
import xarray
import numpy as np

__all__ = ["altitude", "density", "precip", "temperature", "ver"]


def _tick_extrema(ax, alt_km) -> None:
    # tick label minimum altitude for clarity
    ax.set_yticks(np.append(ax.get_yticks(), [alt_km[0], alt_km[-1]]))
    ax.set_ylim(alt_km[0], alt_km[-1])


def density(iono: xarray.Dataset) -> None:
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

    _tick_extrema(ax, iono.alt_km)


def precip(precip: xarray.DataArray) -> None:
    ax = figure().gca()
    ax.plot(precip["energy"] / 1e3, precip, marker=".", linestyle="none")
    ax.set_xscale("log")

    ax.set_xlabel("Energy bin centers [keV]")
    ax.set_ylabel("hemispherical flux [cm$^{-2}$ s$^{-1}$ eV$^{-1}$]")
    ax.set_title("precipitation: differential number flux")
    ax.grid(True)


def temperature(iono: xarray.Dataset) -> None:
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

    _tick_extrema(ax, iono.alt_km)


def altitude(alt_km) -> None:
    ax = figure().gca()
    ax.plot(alt_km, marker=".", linestyle="none")
    ax.set_xlabel("altitude grid index #")
    ax.set_ylabel("altitude [km]")
    ax.set_title(f"altitude grid [km]: # of points {alt_km.size}")
    ax.grid(True)

    _tick_extrema(ax, alt_km)


def ver(iono: xarray.Dataset) -> None:
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

    ax = axs[0]
    ax.set_ylabel("altitude [km]")
    ax.set_xlabel("Volume Emission Rate [photons cm^{-3} s^{-1}]")

    _tick_extrema(ax, iono.alt_km)


def vcb(iono: xarray.Dataset) -> None:
    time = iono.time
    location = iono.glatlon
    tail = f"\n{time} {location}"

    fig = figure(constrained_layout=True)
    ax = fig.gca()

    ax.set_title(tail)

    print(iono["vcb"])

    ax.scatter(iono.wavelength, iono["vcb"])
    ax.set_ylabel("vertical column brightness [Rayleighs]")
    ax.set_xlabel("wavelength [nm]")


def ver_group(iono: xarray.DataArray, ttxt: str, ax) -> None:
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
    ax.set_title(ttxt)
    ax.grid(True)
    ax.legend()

    _tick_extrema(ax, iono.alt_km)
