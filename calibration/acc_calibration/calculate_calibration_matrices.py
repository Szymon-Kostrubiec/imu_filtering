import numpy as np
import pandas as pd
from scipy.optimize import minimize

acc_data = []

def calculate_matrices(x):
    T = np.array([
        [1, 0, 0],
        [x[0], 1, 0],
        [x[1], x[2], 1]
    ])
    S = np.array([
        [x[3], 0, 0],
        [0, x[4], 0],
        [0, 0, x[5]]
    ])
    b = np.array([x[6], x[7], x[8]])

    return T, S, b

def cost_function(x):
    # x is 9 element vector
    T, S, b = calculate_matrices(x)

    transform = lambda x : T @ S @ x + b
    cost = 0
    g_vector = np.array([0, 0, 9.81])
    for i in range(len(acc_data)):
        cost += np.linalg.norm(transform(acc_data[i][:]) - g_vector)

    return cost

# load all positions
for i in range(1, 24):
    filename = 'accel_readings_' + str(i) + '.csv'
    data = pd.read_csv(filename, header=None)
    acc_data.append(np.mean(data, axis=0))

x0 = [0, 0, 0 , 1, 1, 1, 0, 0, 0]

result = minimize(fun=cost_function, x0=x0)

print(f'Solution status: {result.success}')
T, s ,b = calculate_matrices(result.x)

print(f'T: {T}')
print(f'S: {s}')
print(f'b: {b}')
