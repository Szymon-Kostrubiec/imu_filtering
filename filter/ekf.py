# Based on: A Low-Cost Dead Reckoning Navigation System for an AUV Using a Robust AHRS

import numpy as np

class EKF:
    def init(self, dt=0.001, acc=None, mag=None):
        self.attitude_state = np.zeros(6)
        self.heading_state = np.zeros(2)

        self.attitude_model_covariance = np.eye(6, 6)
        self.heading_model_covariance = np.eye(2, 2)
        self.accelerometer_cutoff_frequency = 0.01
    
    def predict(self, gyro, dt):
        # predict - attitude filter

        # state prediction
        self.attitude_state[0:3] = np.eye(3, 3) - self.skew_symmetric_matrix(gyro) * dt @ \
            self.attitude_state[0:3] + dt * self.skew_symmetric_matrix(self.attitude_state[4:6]) @ self.attitude_state[0:3]
        # self.state[3:6] = self.state[3:6] # bias prediction

        # covariance prediction
        jacobian = np.eye(6, 6)
        upper_left = np.eye(3, 3) - self.skew_symmetric_matrix(gyro) * dt + \
            self.skew_symmetric_matrix(self.b) * dt
        jacobian[0:3, 0:3] = upper_left
        jacobian[0:3, 3:6] = dt * self.skew_symmetric_matrix(-self.attitude_state[0:3])

        gyroscope_noise_covariance = np.eye(3, 3) # todo: find/tune values
        gyroscope_bias_covariance = np.eye(3, 3)
        process_noise_covariance = np.eye(6, 6)
        process_noise_covariance[0:3, 0:3] = -dt**2 * gyroscope_noise_covariance @ \
            self.skew_symmetric_matrix(self.attitude_state[0:3]) @ gyroscope_noise_covariance @ \
            self.skew_symmetric_matrix(self.attitude_state[0:3])
        process_noise_covariance[3:6, 3:6] = gyroscope_bias_covariance

        self.attitude_model_covariance = jacobian @ self.attitude_model_covariance @ jacobian.T + process_noise_covariance

        # predict - heading filter
        state_transition = np.eye(2, 2)
        [phi, theta, psi] = self.determine_euler_angles()
        state_transition[0, 1] = -dt * np.cos(phi) / np.cos(theta)
        self.heading_state = state_transition @ self.heading_state
        process_noise_covariance = np.eye(2, 2) @ \
            [dt**2 * gyroscope_noise_covariance[2, 2], gyroscope_bias_covariance[2, 2]]
        self.heading_model_covariance = \
            state_transition @ self.heading_model_covariance @ state_transition.T + process_noise_covariance
        self.heading_model_covariance = 0

    def update_attitude(self, acc, gyro, dt):
        self.predict(gyro, dt)
        a_priori_acceleration = np.cross([0, 0, gravity_observation], self.attitude_state[0:3])
        gravity_observation = 1
        measurement_vector = acc - self.accelerometer_cutoff_frequency * a_priori_acceleration

        observation_matrix = np.zeros(3, 6)
        observation_matrix[0:3, 0:3] = np.eye(3, 3) * gravity_observation

        measurement_covariance = np.eye(3, 3) * 0.01 # todo: find/tune values

        innovation_covariance = observation_matrix @ self.attitude_model_covariance @ observation_matrix.T \
            + measurement_covariance
        
        kalman_gain = self.attitude_model_covariance @ observation_matrix.T @ \
            np.linalg.inv(innovation_covariance)
        
        # update state estimate
        self.attitude_state = self.attitude_state + kalman_gain @ \
            (measurement_vector - observation_matrix @ self.attitude_state)

    def update_heading(self, mag, gyro, dt):
        self.predict(gyro, dt)

        observation_matrix = np.array([1, 0])
        measurement_covariance = 0.01**2 # todo: find/tune values

        innovation_covariance = observation_matrix @ self.heading_model_covariance @ observation_matrix.T \
            + measurement_covariance
        kalman_gain = self.heading_model_covariance @ observation_matrix.T @ \
            np.linalg.inv(innovation_covariance)
        self.heading_state = self.heading_state + kalman_gain @ (mag - self.heading_state[0])
        self.heading_model_covariance = (np.eye(2, 2) - kalman_gain @ observation_matrix) @ self.heading_model_covariance


    def determine_euler_angles(self):
        phi = np.arctan2(self.attitude_state[1], self.attitude_state[2])
        theta = np.arcsin(-self.attitude_state[0])
        psi = self.heading_state[0]

        return [phi, theta, psi]

    def skew_symmetric_matrix(w):
        return np.array([[0, -w[2], w[1]], [w[2], 0, -w[0]], [-w[1], w[0], 0]])