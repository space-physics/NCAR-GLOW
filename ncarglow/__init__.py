import subprocess
from pathlib import Path
from datetime import datetime
from typing import Tuple
import io
import numpy as np

NALT = 250

EXE = Path(__file__).resolve().parents[1] / 'build' / 'glow.bin'
if not EXE.is_file():
    raise FileNotFoundError(f'{EXE} is missing, did you compile GLOW?')


def simple(time: datetime, glat: float, glon: float,
           f107a: float, f107: float, f107p: float, Ap: int,
           Q: float, Echar: float, Nbins: int) -> dict:

    idate, utsec = glowdate(time)

    cmd = [str(EXE), idate, utsec, str(glat), str(glon),
           str(f107a), str(f107), str(f107p), str(Ap), str(Q),
           str(Echar), str(Nbins)]

    dat = subprocess.check_output(cmd, timeout=15,
                                  stderr=subprocess.DEVNULL,
                                  universal_newlines=True)

    iono = glowparse(dat)

    return iono


def glowparse(dat: str) -> dict:

    table = io.StringIO(dat)

    data = {}
    data['dens'] = np.loadtxt(table, skiprows=2, max_rows=NALT)

    data['ver'] = np.loadtxt(table, skiprows=1, max_rows=NALT)

    data['production'] = np.loadtxt(table, skiprows=0, max_rows=NALT)

    data['loss'] = np.loadtxt(table, max_rows=NALT)

    Nbins = int(np.loadtxt(table, max_rows=1))
    data['Ebin_centers'] = np.loadtxt(table, max_rows=1)
    data['Eflux'] = np.loadtxt(table, max_rows=1)

    assert Nbins == data['Ebin_centers'].size == data['Eflux'].size

    return data


def glowdate(t: datetime) -> Tuple[str, str]:

    idate = f'{t.year}{t.strftime("%j")}'
    utsec = str(t.hour*3600 + t.minute*60 + t.second)

    return idate, utsec
