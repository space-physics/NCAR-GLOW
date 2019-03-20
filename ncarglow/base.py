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
           Q: float, Echar: float, Nbins: int) -> xarray.Dataset:

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
          Ebins: np.ndarray, Phitop: np.ndarray) -> xarray.Dataset:

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


def glowparse(raw: str) -> xarray.Dataset:

    table = io.StringIO(raw)

    dat = np.genfromtxt(table, skip_header=2, max_rows=NALT)
    alt_km = dat[:, 0]

    states = ['Tn', 'O', 'N2', 'N', 'NO', 'NeIn', 'NeOut', 'ionrate',
              'O+', 'O2+', 'NO+', 'N2D', 'pedersen', 'hall']

    d: dict = {k: ('alt_km', v) for (k, v) in zip(states, dat[:, 1:].T)}

# %% VER
    dat = np.genfromtxt(table, skip_header=1, max_rows=NALT)

    wavelen = ['A3371', 'A4278', 'A5200', 'A5577', 'A6300', 'A7320', 'A10400',
               'A3644', 'A7774', 'A8446', 'A3726', 'LBH', 'A1356', 'A1493', 'A1304']

    d.update({k: ('alt_km', v) for (k, v) in zip(wavelen, dat[:, 1:].T)})

    iono = xarray.Dataset(d, coords={'alt_km': alt_km})
# %% production & loss
    d = {'production': (('alt_km', 'state'), np.genfromtxt(table, skip_header=0, max_rows=NALT)[:, 1:]),
         'loss': (('alt_km', 'state'), np.genfromtxt(table, max_rows=NALT)[:, 1:])}

    state = ['O+(2P)', 'O+(2D)', 'O+(4S)', 'N+', 'N2+', 'O2+', 'NO+', 'N2(A)',
             'N(2P)', 'N(2D)', 'O(1S)', 'O(1D)']

    prodloss = xarray.Dataset(d, coords={'alt_km': alt_km,
                                         'state': state})
# %% precip input
    Nbins = int(np.genfromtxt(table, max_rows=1))
    E = np.genfromtxt(table, max_rows=1)
    Eflux = np.genfromtxt(table, max_rows=1)
    precip = xarray.Dataset({'precip': ('energy', Eflux)}, coords={'energy': E})

    assert E.size == Nbins

# %% assemble output
    iono = xarray.merge((iono, prodloss, precip))

    return iono


def glowdate(t: datetime) -> Tuple[str, str]:

    idate = f'{t.year}{t.strftime("%j")}'
    utsec = str(t.hour*3600 + t.minute*60 + t.second)

    return idate, utsec
