clear; close all; clc;

load measurements.mat;

euler_angles = zeros(600, 3);

for i=1:600
    rot_quat = ecompass(accelReadings(i, :), magReadings(i, :));

    euler_angles(i, :) = quat2eul(rot_quat);
end

load gt.mat;

figure;
subplot(311);
hold on;
plot(euler_angles_gt(:, 1), 'k');
plot(euler_angles(:, 1), 'r');
subplot(312);
hold on;
plot(euler_angles_gt(:, 2), 'k');
plot(euler_angles(:, 2), 'r');
subplot(313);
hold on;
plot(euler_angles_gt(:, 3), 'k');
plot(euler_angles(:, 3), 'r');