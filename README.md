[![DOI](https://zenodo.org/badge/162534283.svg)](https://zenodo.org/badge/latestdoi/162534283)

[![Actions Status](https://github.com/scivision/NCAR-GLOW/workflows/ci_linux/badge.svg)](https://github.com/scivision/NCAR-GLOW/actions)
[![Actions Status](https://github.com/scivision/NCAR-GLOW/workflows/ci_macos/badge.svg)](https://github.com/scivision/NCAR-GLOW/actions)
[![Actions Status](https://github.com/scivision/NCAR-GLOW/workflows/ci_windows/badge.svg)](https://github.com/scivision/NCAR-GLOW/actions)

# GLOW

The GLobal airglOW Model, independently and easily accessed from **Fortran 2003** compiler.
Optionally available from scripting languages including:

* Python &ge; 3.6
* Matlab
* GNU Octave &ge; 4.2
* IDL / GDL

We describe each language below; pick the one(s) that apply for you.
Python is the easiest and recommennded choice.
A Fortran compiler is required in any case.

## Python

Install/compile by:

```sh
git clone https://github.com/space-physics/ncar-glow

pip install -e ncar-glow
```

Confirm the install with:

```sh
pytest ncar-glow
```

Then use examples such as:

* Simple.py:  Maxwellian precipiation, specify Q and E0.
* Monoenergetic.py: Specify unit flux for one energy bin, all other energy bins are zero flux.

or use GLOW in your own Python program by:
```python
import ncarglow as glow

iono = glow.simple(time, glat, glon, Q, Echar, Nbins)
```

`iono` is an
[xarray.Dataset](http://xarray.pydata.org/en/stable/generated/xarray.Dataset.html)
containing outputs from GLOW, including:

* number densities of neutrals, ions and electrons
* Pedersen and Hall currents
* volume emssion rate vs. wavelength and altitude
* precipitating flux vs. energy
* many more, request if you want it.

## Fortran

You can call this repo from a Meson wrap or CMake Fetch.
To build Fortran code by itself, do either:

```sh
meson build

meson test -C build
```

or

```sh
cmake -B build

cmake --build build
```

### MPI / NetCDF

The parallel version of GLOW requires MPI and NetCDF for TIEGCM I/O.
```sh
mpirun -np 2 ./mpi_glow.bin < ~/data/in.namelist.tgcm
```

Note, for an unknown reason, `in.namelist.msis` only works with -O0 or -O1 with gfortran 7. We didn't look into why.
Otherwise, -O3 works fine.

## Matlab / GNU Octave

The Matlab interface is in the [matlab](./matlab) directory, and passes data to / from Glow over stdin / stdout pipes.

* Use built-in energy and altitude bins: [Simple.m](./matlab/Simple.m)
* user input energy grid: [Monoenergetic.m](./matlab/Monoenergetic.m)

NOTE: if using GNU Octave, version &ge; 4.2 is required for proper [textscan() functionality](https://www.gnu.org/software/octave/NEWS-4.2.html)

## IDL / GDL

We have a small script for IDL / GDL thanks to Guy Grubbs.
Let us know if you want this, we haven't taken the time to upload it yet.
