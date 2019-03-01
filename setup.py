#!/usr/bin/env python
import setuptools  # noqa: F401
from pathlib import Path
import os
import subprocess


R = Path(__file__).parent / 'data'
iridata = list(map(str, (R / 'iri90').glob('*.asc')))
snoemdata = list(map(str, R.glob('*.dat')))


setuptools.setup(
    data_files=snoemdata + iridata,
)

Rb = Path(__file__).resolve().parent
BINDIR = Rb / 'build'
SRCDIR = Rb / 'src'


def cmake_setup():
    if os.name == 'nt':
        subprocess.check_call(['cmake', '-G', 'MinGW Makefiles',
                               '-DCMAKE_SH="CMAKE_SH-NOTFOUND', str(SRCDIR)],
                              cwd=BINDIR)
    else:
        subprocess.check_call(['cmake', str(SRCDIR)],
                              cwd=BINDIR)

    subprocess.check_call(['cmake', '--build', str(BINDIR), '-j'])


def meson_setup():
    subprocess.check_call(['meson', str(SRCDIR)], cwd=BINDIR)
    subprocess.check_call(['ninja'], cwd=BINDIR)


try:
    meson_setup()
except Exception:
    cmake_setup()
