[![Build Status](https://travis-ci.com/scivision/NCAR-GLOW.svg?branch=cmake)](https://travis-ci.com/scivision/NCAR-GLOW)

# GLOW
The GLobal airglOW Model

* Fortran-90 source code files,
* Makefiles,
* Example input and output files,
* Example job script,
* Subdirectory data/ contains input data files,
* Subdirectory data/iri90 contains IRI input data files


## Build
You can call this repo from a Meson wrap or CMake Fetch.
To build by itself, do either:


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

## Matlab / GNU Octave

The Matlab and Python interfaces work similarly.
Matlab code is in the [matlab](./matlab) directory, and passes data to / from Glow over stdin / stdout pipes.

* Use built-in energy and altitude bins: [Simple.m](./matlab/Simple.m)
* user input energy grid: [EnergyGrid.m](./matlab/EnergyGrid.m)

NOTE: if using GNU Octave, version &ge; 4.2 is required for proper [textscan() functionality](https://www.gnu.org/software/octave/NEWS-4.2.html)
