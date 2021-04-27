"""
A generic, clean way to build C/C++/Fortran code from setup.py or manually

Michael Hirsch, Ph.D.
https://www.scivision.dev
"""

import shutil
from pathlib import Path
import subprocess
import os

R = Path(__file__).resolve().parent
SRCDIR = R
BINDIR = SRCDIR / "build"


def build(build_sys: str, src_dir: Path = SRCDIR, bin_dir: Path = BINDIR):
    """
    attempts build with Meson or CMake
    """
    if build_sys == "meson":
        meson_setup(src_dir, bin_dir)
    elif build_sys == "cmake":
        cmake_setup(src_dir, bin_dir)
    else:
        raise ValueError(f"Unknown build system {build_sys}")


def cmake_setup(src_dir: Path, bin_dir: Path):
    """
    attempt to build using CMake >= 3
    """
    cmake_exe = shutil.which("cmake")
    if not cmake_exe:
        raise FileNotFoundError("CMake not available")

    wopts = ["-G", "MinGW Makefiles"] if os.name == "nt" else []

    subprocess.check_call([cmake_exe, "-S", str(src_dir), "-B", str(bin_dir)] + wopts)

    subprocess.check_call([cmake_exe, "--build", str(bin_dir), "--parallel"])


def meson_setup(src_dir: Path, bin_dir: Path):
    """
    attempt to build with Meson + Ninja
    """
    meson_exe = shutil.which("meson")

    if not meson_exe:
        raise FileNotFoundError("Meson not available")

    if not (bin_dir / "build.ninja").is_file():
        subprocess.check_call([meson_exe, "setup", str(bin_dir), str(src_dir)])

    subprocess.check_call([meson_exe, "compile", "-C", str(bin_dir)])
