import subprocess
from pathlib import Path
from datetime import datetime, timedelta
from typing import Tuple
import io
import numpy as np
import xarray
import os
import tempfile

import geomagindices as gi
from .build import build

NALT = 250

EXE = Path(__file__).resolve().parents[1] / 'build' / 'glow.bin'
if os.name == 'nt':
    EXE = EXE.with_suffix('.bin.exe')
if not EXE.is_file():
    build()


def simple(time: datetime, glat: float, glon: float,
           Q: float, Echar: float, Nbins: int) -> tuple:

    idate, utsec = glowdate(time)

    ionoparams = gi.getApF107(time, 81)
    ionoparams_prevday = gi.getApF107(time-timedelta(days=1), 81)

    cmd = [str(EXE), idate, utsec, str(glat), str(glon),
           str(ionoparams['f107s'].item()), str(ionoparams['f107'].item()),
           str(ionoparams_prevday['f107'].item()),
           str(ionoparams['Ap'].item()),
           str(Q), str(Echar), str(Nbins)]

    dat = subprocess.check_output(cmd, timeout=15,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True)

    return glowparse(dat)


def ebins(time: datetime, glat: float, glon: float,
          Ebins: np.ndarray, Phitop: np.ndarray) -> tuple:

    idate, utsec = glowdate(time)

# %% Matlab compatible workaround (may change to use stdin in future)
    Efn = Path(tempfile.mkstemp('.dat')[1])
    with Efn.open('wb') as f:
        Ebins.tofile(f)
        Phitop.tofile(f)

    tmpfile_size = Efn.stat().st_size
    expected_size = (Ebins.size + Phitop.size)*4
    if tmpfile_size != expected_size:
        raise OSError(f'{Efn} size {tmpfile_size} != {expected_size}')

    ionoparams = gi.getApF107(time, 81)
    ionoparams_prevday = gi.getApF107(time-timedelta(days=1), 81)

    cmd = [str(EXE), idate, utsec, str(glat), str(glon),
           str(ionoparams['f107s'].item()), str(ionoparams['f107'].item()),
           str(ionoparams_prevday['f107'].item()),
           str(ionoparams['Ap'].item()),
           '-e', str(Ebins.size), str(Efn)]

    ret = subprocess.run(cmd, timeout=15, universal_newlines=True, stdout=subprocess.PIPE)
    if ret.returncode:
        raise RuntimeError(f'GLOW failed at {time}')
    try:
        Efn.unlink()
    except PermissionError:
        pass

    return glowparse(ret.stdout)


def glowparse(raw: str) -> tuple:

    table = io.StringIO(raw)

    dat = np.genfromtxt(table, skip_header=2, max_rows=NALT)
    alt_km = dat[:, 0]

    iono = xarray.Dataset(coords={'alt_km': alt_km})

    iono['Tn'] = dat[:, 1]
    iono['O'] = dat[:, 2]
    iono['N2'] = dat[:, 3]
    iono['NO'] = dat[:, 4]
    iono['NeIn'] = dat[:, 5]
    iono['NeOut'] = dat[:, 6]
    iono['ionrate'] = dat[:, 7]
    iono['O+'] = dat[:, 8]
    iono['O2+'] = dat[:, 9]
    iono['NO+'] = dat[:, 10]
    iono['N2D'] = dat[:, 11]
    iono['pedersen'] = dat[:, 12]
    iono['hall'] = dat[:, 13]
# %% VER
    dat = np.genfromtxt(table, skip_header=1, max_rows=NALT)

    if (dat[:, 0] != iono['alt_km']).any():
        raise ValueError('altitude grids not matching between density and VER')

    iono['A3371'] = dat[:, 1]
    iono['A4278'] = dat[:, 2]
    iono['A5200'] = dat[:, 3]
    iono['A5577'] = dat[:, 4]
    iono['A6300'] = dat[:, 5]
    iono['A7320'] = dat[:, 6]
    iono['A10400'] = dat[:, 7]
    iono['A3644'] = dat[:, 8]
    iono['A7774'] = dat[:, 9]
    iono['A8446'] = dat[:, 10]
    iono['A3726'] = dat[:, 11]
    iono['LBH'] = dat[:, 12]
    iono['A1356'] = dat[:, 13]
    iono['A1493'] = dat[:, 14]
    iono['A1304'] = dat[:, 15]
# %% production & loss
    production = np.genfromtxt(table, skip_header=0, max_rows=NALT)[:, 1:]

    loss = np.genfromtxt(table, max_rows=NALT)[:, 1:]
# %% precip input
    Nbins = int(np.genfromtxt(table, max_rows=1))
    E = np.genfromtxt(table, max_rows=1)
    Eflux = np.genfromtxt(table, max_rows=1)
    precip = xarray.Dataset({'Eflux': Eflux}, coords={'Energy': E})

    assert E.size == Nbins

    return iono, precip, production, loss


def glowdate(t: datetime) -> Tuple[str, str]:

    idate = f'{t.year}{t.strftime("%j")}'
    utsec = str(t.hour*3600 + t.minute*60 + t.second)

    return idate, utsec
