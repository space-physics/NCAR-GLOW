import shutil
import pytest
import ncarglow.build as build
from pathlib import Path

R = Path(__file__).parent


@pytest.mark.parametrize("build_sys", ["cmake", "meson"])
def test_build(build_sys, tmp_path):
    if not shutil.which(build_sys):
        pytest.skip(f"{build_sys} not available")

    build.build(build_sys, R.parent, tmp_path)


def test_bad_build(tmp_path):
    with pytest.raises(ValueError):
        build.build("fake", R.parent, tmp_path)
