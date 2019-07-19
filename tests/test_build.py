#!/usr/bin/env python
import pytest
import ncarglow.build as build
from pathlib import Path

R = Path(__file__).parent


@pytest.mark.parametrize('build_sys', ['cmake', 'meson'])
def test_build(build_sys, tmp_path):
    build.build(build_sys, R.parent, tmp_path)


def test_bad(tmp_path):
    with pytest.raises(ValueError):
        build.build('fake', R.parent, tmp_path)


if __name__ == '__main__':
    pytest.main(['-r', 'a', '-v', '-s', __file__])
