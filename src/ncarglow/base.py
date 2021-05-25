from __future__ import annotations
import subprocess
from pathlib import Path
from datetime import datetime, timedelta
import io
import numpy as np
import xarray
import tempfile
import pandas
import shutil
import importlib.resources

import geomagindices as gi
from .build import build

NALT = 250
var = [
    "Tn",
    "O",
    "N2",
    "O2",
    "NO",
    "NeIn",
    "NeOut",
    "ionrate",
    "O+",
    "O2+",
    "NO+",
    "N2D",
    "pedersen",
    "hall",
]

BINPATH = "build"


def get_exe(name: str = "glow.bin") -> Path:

    with importlib.resources.path(__package__, "CMakeLists.txt") as cml:
        src_dir = cml.parent
        bin_dir = src_dir / BINPATH
        exe = shutil.which(name, path=str(bin_dir))
        if not exe:
            try:
                build("meson")
            except Exception:
                build("cmake")

        exe = shutil.which(name, path=str(bin_dir))
        if not exe:
            raise ImportError(
                "GLOW executable not available. This is probably a Python package bug."
            )

    return Path(exe)


def maxwellian(
    time: datetime, glat: float, glon: float, Q: float, Echar: float, Nbins: int
) -> xarray.Dataset:

    idate, utsec = glowdate(time)

    ip = gi.get_indices([time - timedelta(days=1), time], 81)

    cmd = [
        str(get_exe()),
        idate,
        utsec,
        str(glat),
        str(glon),
        str(ip["f107s"][1]),
        str(ip["f107"][1]),
        str(ip["f107"][0]),
        str(ip["Ap"][1]),
        str(Q),
        str(Echar),
        str(Nbins),
    ]

    dat = subprocess.check_output(cmd, timeout=15, stderr=subprocess.DEVNULL, text=True)

    return glowread(dat, time, ip, glat, glon)


def no_precipitation(time: datetime, glat: float, glon: float, Nbins: int) -> xarray.Dataset:

    idate, utsec = glowdate(time)

    ip = gi.get_indices([time - timedelta(days=1), time], 81)

    cmd = [
        str(get_exe()),
        idate,
        utsec,
        str(glat),
        str(glon),
        str(ip["f107s"][1]),
        str(ip["f107"][1]),
        str(ip["f107"][0]),
        str(ip["Ap"][1]),
        "-noprecip",
        str(Nbins),
    ]

    dat = subprocess.check_output(cmd, timeout=15, stderr=subprocess.DEVNULL, text=True)

    return glowread(dat, time, ip, glat, glon)


def no_source(
    time: datetime, glat: float, glon: float, Nbins: int, Talt: float, Thot: float
) -> xarray.Dataset:
    """testing only, may give non-physical results"""
    idate, utsec = glowdate(time)

    ip = gi.get_indices([time - timedelta(days=1), time], 81)

    cmd = [
        str(get_exe()),
        idate,
        utsec,
        str(glat),
        str(glon),
        str(ip["f107s"][1]),
        str(ip["f107"][1]),
        str(ip["f107"][0]),
        str(ip["Ap"][1]),
        "-nosource",
        str(Nbins),
        str(Talt),
        str(Thot),
    ]

    dat = subprocess.check_output(cmd, timeout=15, stderr=subprocess.DEVNULL, text=True)

    return glowread(dat, time, ip, glat, glon)


def ebins(
    time: datetime, glat: float, glon: float, Ebins: np.ndarray, Phitop: np.ndarray
) -> xarray.Dataset:

    idate, utsec = glowdate(time)

    # %% Matlab compatible workaround (may change to use stdin in future)
    Efn = Path(tempfile.mkstemp(".dat")[1])
    with Efn.open("wb") as f:
        Ebins.tofile(f)
        Phitop.tofile(f)

    tmpfile_size = Efn.stat().st_size
    expected_size = (Ebins.size + Phitop.size) * 4
    if tmpfile_size != expected_size:
        raise OSError(f"{Efn} size {tmpfile_size} != {expected_size}")

    ip = gi.get_indices([time - timedelta(days=1), time], 81)

    cmd = [
        str(get_exe()),
        idate,
        utsec,
        str(glat),
        str(glon),
        str(ip["f107s"][1]),
        str(ip["f107"][1]),
        str(ip["f107"][0]),
        str(ip["Ap"][1]),
        "-e",
        str(Ebins.size),
        str(Efn),
    ]

    ret = subprocess.run(cmd, timeout=15, text=True, stdout=subprocess.PIPE)
    if ret.returncode:
        raise RuntimeError(f"GLOW failed at {time}")
    try:
        Efn.unlink()
    except PermissionError:
        # Windows sometimes does this if something else is holding the file open.
        # this is also why we don't use a tempfile context manager for this application.
        pass

    return glowread(ret.stdout, time, ip, glat, glon)


def glowread(
    raw: str, time: datetime, ip: pandas.DataFrame, glat: float, glon: float
) -> xarray.Dataset:

    iono = glowparse(raw)
    iono.attrs["geomag_params"] = ip
    iono.attrs["time"] = time.isoformat()
    iono.attrs["glatlon"] = (glat, glon)

    return iono


def glowparse(raw: str) -> xarray.Dataset:

    table = io.StringIO(raw)

    dat = np.genfromtxt(table, skip_header=2, max_rows=NALT)
    alt_km = dat[:, 0]

    if len(var) != dat.shape[1] - 1:
        raise ValueError("did not read raw output from GLOW correctly, please file a bug report.")

    d: dict = {k: ("alt_km", v) for (k, v) in zip(var, dat[:, 1:].T)}
    iono = xarray.Dataset(d, coords={"alt_km": alt_km})
    # %% VER
    dat = np.genfromtxt(table, skip_header=1, max_rows=NALT)
    assert dat[0, 0] == alt_km[0]
    wavelen = [
        3371,
        4278,
        5200,
        5577,
        6300,
        7320,
        10400,
        3644,
        7774,
        8446,
        3726,
        "LBH",
        1356,
        1493,
        1304,
    ]

    ver = xarray.DataArray(
        dat[:, 1:],
        coords={"alt_km": alt_km, "wavelength": wavelen},
        dims=["alt_km", "wavelength"],
        name="ver",
    )
    # %% production & loss
    d = {
        "production": (
            ("alt_km", "state"),
            np.genfromtxt(table, skip_header=0, max_rows=NALT)[:, 1:],
        ),
        "loss": (("alt_km", "state"), np.genfromtxt(table, max_rows=NALT)[:, 1:]),
    }

    state = [
        "O+(2P)",
        "O+(2D)",
        "O+(4S)",
        "N+",
        "N2+",
        "O2+",
        "NO+",
        "N2(A)",
        "N(2P)",
        "N(2D)",
        "O(1S)",
        "O(1D)",
    ]

    prodloss = xarray.Dataset(d, coords={"alt_km": alt_km, "state": state})  # type: ignore
    # %% precip input
    Nbins = int(np.genfromtxt(table, max_rows=1))
    E = np.genfromtxt(table, max_rows=1)
    Eflux = np.genfromtxt(table, max_rows=1)
    precip = xarray.Dataset({"precip": ("energy", Eflux)}, coords={"energy": E})

    assert E.size == Nbins
    # %% excited / ionized densities
    dat = np.genfromtxt(table, skip_header=1, max_rows=NALT)
    assert dat[0, 0] == alt_km[0]
    d = {"excitedDensity": (("alt_km", "state"), dat[:, 1:])}
    excite = xarray.Dataset(d, coords=prodloss.coords)  # type: ignore
    # %% Te, Ti
    dat = np.genfromtxt(table, skip_header=1, max_rows=NALT)
    assert dat[0, 0] == alt_km[0]
    iono["Te"] = ("alt_km", dat[:, 1])
    iono["Ti"] = ("alt_km", dat[:, 2])
    # %% assemble output
    iono = xarray.merge((iono, ver, prodloss, precip, excite))

    return iono


def glowdate(t: datetime) -> tuple[str, str]:

    idate = f'{t.year}{t.strftime("%j")}'
    utsec = str(t.hour * 3600 + t.minute * 60 + t.second)

    return idate, utsec
