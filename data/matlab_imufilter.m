clear; close all; clc;

gyro_readings_time = readmatrix("gyro_readings.csv");
time = gyro_readings_time(:, 1);
gyro_readings = gyro_readings_time(1:5000, 2:4);
% time resolution is not enough, stm32 should time stamp the readings
time = diff(time);

gyro_readings(abs(gyro_readings) > 20) = 0; % correct communication errors

w = gyro_readings(:, 1);
u = gyro_readings(:, 2);
v = gyro_readings(:, 3);

acc_readings_time = readmatrix("accel_readings.csv");
time = acc_readings_time(:, 1);
acc_readings = acc_readings_time(1:5000, 2:4);

a_x = acc_readings(:, 1);
a_y = acc_readings(:, 2);
a_z = acc_readings(:, 3);

imu_filter = imufilter('SampleRate', 1000);

% todo: poor performance, maybe some tuning
% hallucinated movement?
q = imu_filter(acc_readings, gyro_readings);

plot(1:1:length(q), eulerd(q, 'ZYX', 'frame'));
title('Orientation Estimate');
legend('Z', 'Y', 'X');
grid on;