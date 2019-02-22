import numpy as np


def alt_tanh(gridmin: float, gridmax: float, Np: int) -> np.ndarray:
    # arbitrarily picking 3.14 as where tanh gets to 99% of asymptote
    x0 = np.linspace(0, 3.14, Np)
    return np.tanh(x0) * gridmax + gridmin
