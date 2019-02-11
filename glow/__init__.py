import numpy as np


def alt_tanh(gridmin: float, gridmax: float, Np: int) -> np.ndarray:
    x0 = np.linspace(0, 3.14, Np)  # arbitrarily picking 3.14 as where tanh gets to 99% of asymptote
    return np.tanh(x0) * gridmax + gridmin
