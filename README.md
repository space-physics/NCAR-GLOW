[![Build Status](https://travis-ci.com/scivision/NCAR-GLOW.svg?branch=cmake)](https://travis-ci.com/scivision/NCAR-GLOW)

# GLOW
The GLobal airglOW Model in Python.
Install/compile by:
```sh
pip install -e .
```

Then use examples such as:

* Simple.py:  Maxwellian precipiation, specify Q and E0.


## Fortran
You can call this repo from a Meson wrap or CMake Fetch.
To build Fortran code by itself, do either:

```sh
meson build

ninja -c build
```

or

```sh
cmake -B build -S .

cmake --build build -j
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
* user input energy grid: [EnergyGrid.m](./matlab/EnergyGrid.m)

NOTE: if using GNU Octave, version &ge; 4.2 is required for proper [textscan() functionality](https://www.gnu.org/software/octave/NEWS-4.2.html)
