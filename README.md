# GLOW

[![DOI](https://zenodo.org/badge/162534283.svg)](https://zenodo.org/badge/latestdoi/162534283)
[![Actions Status](https://github.com/scivision/NCAR-GLOW/workflows/ci/badge.svg)](https://github.com/scivision/NCAR-GLOW/actions)

The GLobal airglOW Model, independently and easily accessed using Fortran compiler.
Available from scripting languages including Python and Matlab.

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

* [Maxwellian.py](https://github.com/space-physics/NCAR-GLOW/blob/main/Examples/Maxwellian.py): Maxwellian precipiation, specify Q and E0.
* [Monoenergetic.py](https://github.com/space-physics/NCAR-GLOW/blob/main/Examples/Monoenergetic.py): Specify unit flux for one energy bin, all other energy bins are zero flux.

or use GLOW in your own Python program by:

```python
import ncarglow as glow

iono = glow.simple(time, glat, glon, Q, Echar, Nbins)
```

`iono` is an
[xarray.Dataset](https://docs.xarray.dev/en/stable/generated/xarray.Dataset.html)
containing outputs from GLOW, including:

* number densities of neutrals, ions and electrons
* Pedersen and Hall currents
* volume emssion rate vs. wavelength and altitude
* precipitating flux vs. energy
* many more, request if you want it.

## Fortran standalone

You can call this repo from a Meson wrap or CMake FetchContent.
To build Fortran code by itself, do either:

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

## Matlab

The Matlab interface is in
[+ncarglow](./+ncarglow/)
passing data to / from Glow over scratch disk binary files.

* Use built-in energy and altitude bins: [Maxwellian.m](./Examples/Maxwellian.m)
* user input energy grid: [Monoenergetic.m](./Examples/Monoenergetic.m)
