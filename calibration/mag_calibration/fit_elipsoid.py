import numpy as np
import pandas as pd

# Load the data
mag_data = pd.read_csv('mag_calibration_data.csv').to_numpy()

def cost_function(x):
    x0, y0, z0, a, b, c = x

    # Calculate the cost
    cost = 0
    for i in range(mag_data.shape[0]):
        x, y, z = mag_data[i, :]
        radius = ((x - x0)**2/a**2 + (y - y0)**2/b**2 + (z - z0)**2/c**2 - 1)**2
        cost += (radius - 1)**2

mean_vector = np.mean(mag_data, axis=0)
x0 = np.random.rand(6)
x0[0:3] = mean_vector

# Optimize the cost function
from scipy.optimize import minimize
result = minimize(cost_function, x0)
print(result.x)
