clear; close all; clc;

% try to estimate bias term, plot the data

dt = 0.001;

gyro_readings_time = readmatrix("gyro_readings.csv");
time = gyro_readings_time(:, 1);
gyro_readings = gyro_readings_time(1:5000, 2:4);
% time resolution is not enough, stm32 should time stamp the readings
time = diff(time);

gyro_readings(abs(gyro_readings) > 20) = 0; % correct communication errors

w = gyro_readings(:, 1);
u = gyro_readings(:, 2);
v = gyro_readings(:, 3);

% find dc component

w_dc = mean(w);
u_dc = mean(u);
v_dc = mean(v);

figure;
subplot(3, 1, 1);
hold on;
plot(w, 'k');
plot(w - w_dc, 'r');
subplot(3, 1, 2);
hold on;
plot(u, 'k');
plot(u - u_dc, 'r');
subplot(3, 1, 3);
hold on;
plot(v, 'k');
plot(v - v_dc, 'r');

"The angle estimation: "
sum((v - v_dc) * 0.001)

clear;

acc_readings_time = readmatrix("accel_readings.csv");
time = acc_readings_time(:, 1);
acc_readings = acc_readings_time(:, 2:4);

a_x = acc_readings(:, 1);
a_y = acc_readings(:, 2);
a_z = acc_readings(:, 3);

figure;
subplot(3, 1, 1);
hold on;
plot(a_x, 'k');
subplot(3, 1, 2);
hold on;
plot(a_y, 'k');
subplot(3, 1, 3);
hold on;
plot(a_z, 'k');

pitch = asin(mean(a_x))
roll = atan(mean(a_y) / mean(a_z))