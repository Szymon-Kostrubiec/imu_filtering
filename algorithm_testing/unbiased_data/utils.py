import numpy as np
from ahrs.common import Quaternion


def quaternion_to_euler(quaternion):
    phi = np.empty(len(quaternion))
    theta = np.empty_like(phi)
    psi = np.empty_like(phi)

    for i in range(len(phi)):
        phi[i], theta[i], psi[i] = Quaternion(quaternion[i]).to_angles()
        if phi[i] < 0:
            phi[i] += 2*np.pi
        if theta[i] < 0:
            theta[i] += 2*np.pi
        if psi[i] < 0:
            psi[i] += 2*np.pi

        if phi[i] > 2*np.pi:
            phi[i] -= 2*np.pi
        if theta[i] > 2*np.pi:
            theta[i] -= 2 * np.pi
        if psi[i] > 2 * np.pi:
            psi[i] -= 2 * np.pi

    phi *= 180.0 / np.pi
    theta *= 180.0 / np.pi
    psi *= 180.0 / np.pi

    return phi, theta, psi

