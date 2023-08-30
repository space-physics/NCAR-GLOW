"""
A generic, clean way to build C/C++/Fortran code from setup.py or manually

SciVision, Inc.
"""

import shutil
import subprocess
import os
import importlib.resources as impr


BINDIR = "build"


def build(build_sys: str):
    """
    attempts build with Meson or CMake
    """
    if build_sys == "meson":
        meson_setup()
    elif build_sys == "cmake":
        cmake_setup()
    else:
        raise ValueError(f"Unknown build system {build_sys}")


def cmake_setup():
    """
    attempt to build using CMake
    """

    cmake_exe = shutil.which("cmake")
    if not cmake_exe:
        raise FileNotFoundError("CMake not available")

    wopts = ["-G", "MinGW Makefiles"] if os.name == "nt" else []

    with impr.as_file(impr.files(__package__)) as src_dir:
        bin_dir = src_dir / BINDIR

        subprocess.check_call([cmake_exe, f"-S{src_dir}", f"-B{bin_dir}"] + wopts)

        subprocess.check_call([cmake_exe, "--build", str(bin_dir), "--parallel"])


def meson_setup():
    """
    attempt to build with Meson + Ninja
    """
    meson_exe = shutil.which("meson")

    if not meson_exe:
        raise FileNotFoundError("Meson not available")

    with impr.as_file(impr.files(__package__)) as src_dir:
        bin_dir = src_dir / BINDIR

        if not (bin_dir / "build.ninja").is_file():
            subprocess.check_call([meson_exe, "setup", str(bin_dir), str(src_dir)])

    subprocess.check_call([meson_exe, "compile", "-C", str(bin_dir)])
