import pandas as pd
import numpy as np
import os

dir_path = os.path.dirname(os.path.realpath(__file__))


def get_data():
    acc = pd.read_csv(os.path.join(dir_path, 'acc.csv')).to_numpy()
    gyro = pd.read_csv(os.path.join(dir_path, 'gyro.csv')).to_numpy()
    mag = pd.read_csv(os.path.join(dir_path, 'mag.csv')).to_numpy()

    return acc, gyro, mag


def get_gt():
    orientation_ned = pd.read_csv(os.path.join(dir_path, 'orientation_gt.csv')).to_numpy()
    return orientation_ned


def get_gt_trajectory():
    acceleration = pd.read_csv(os.path.join(dir_path, 'acc_body_gt.csv')).to_numpy()
    angular_vel = pd.read_csv(os.path.join(dir_path, 'ang_vel_body_gt.csv')).to_numpy()

    return acceleration, angular_vel


if __name__ == '__main__':
    get_data()
    get_gt()