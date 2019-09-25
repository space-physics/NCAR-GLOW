#!/usr/bin/env python

from matplotlib.pyplot import figure, show
import futils

alt = futils.utils.alt_grid(250, 60, 0.5, 4)

ax = figure().gca()
ax.plot(alt, marker=".", linestyle="none")
ax.set_xlabel("index")
ax.set_ylabel("altitude")
ax.legend()
show()
