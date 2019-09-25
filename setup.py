#!/usr/bin/env python
import setuptools  # noqa: F401
from pathlib import Path

R = Path(__file__).parent / "data"
iridata = list(map(str, (R / "iri90").glob("*.asc")))
snoemdata = list(map(str, R.glob("*.dat")))


setuptools.setup(data_files=snoemdata + iridata)
