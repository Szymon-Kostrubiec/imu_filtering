clear; close all; clc;

gyro_readings_time = readmatrix("gyro_readings.csv");
gyro_readings = gyro_readings_time(1:5000, 2:4);

acc_readings_time = readmatrix("accel_readings.csv");
acc_readings = acc_readings_time(:, 2:4);

a_x = acc_readings(:, 1);
a_y = acc_readings(:, 2);
a_z = acc_readings(:, 3);

w = gyro_readings(:, 1);
u = gyro_readings(:, 2);
v = gyro_readings(:, 3);

Fs = 1000;
Ts = 1/Fs;

test_signal = w;

Y = fft(test_signal);
P2 = abs(Y / length(test_signal));
P1 = P2(1:length(test_signal)/2+1);

P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(length(test_signal)/2))/length(test_signal);

plot(f, P1, 'k');
title("PSD");
grid on;
ylabel("Magnitude");
xlabel("Frequency (Hz)");

