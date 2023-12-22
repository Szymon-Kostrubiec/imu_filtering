clear; close all; clc;

fs = 100;
dt = 1 / fs;
firstLoopNumSamples = fs*4;
secondLoopNumSamples = fs*2;
totalNumSamples = firstLoopNumSamples + secondLoopNumSamples;

traj = kinematicTrajectory('SampleRate',fs);

accBody = zeros(totalNumSamples,3);
angVelBody = zeros(totalNumSamples,3);
angVelBody(1:firstLoopNumSamples,3) = (2*pi)/4;
angVelBody(firstLoopNumSamples+1:end,3) = (2*pi)/2;

[~,orientationNED,~,accNED,angVelNED] = traj(accBody,angVelBody);

IMU = imuSensor('accel-gyro-mag','SampleRate',fs);

IMU.Accelerometer = accelparams( ...
    'MeasurementRange',19.62, ...            % m/s^2
    'Resolution',0.0023936, ...              % m/s^2 / LSB
    'TemperatureScaleFactor',0.008, ...      % % / degree C
    'ConstantBias',0.1962, ...               % m/s^2
    'TemperatureBias',0.0014715, ...         % m/s^2 / degree C
    'NoiseDensity',0.0012361);               % m/s^2 / Hz^(1/2)

IMU.Magnetometer = magparams( ...
    'MeasurementRange',1200, ...             % uT
    'Resolution',0.1, ...                    % uT / LSB
    'TemperatureScaleFactor',0.1, ...        % % / degree C
    'ConstantBias',1, ...                    % uT
    'TemperatureBias',[0.8 0.8 2.4], ...     % uT / degree C
    'NoiseDensity',[0.6 0.6 0.9]/sqrt(100)); % uT / Hz^(1/2)

IMU.Gyroscope = gyroparams( ...
    'MeasurementRange',4.3633, ...
    'Resolution',0.00013323, ...
    'AxesMisalignment',2, ...
    'NoiseDensity',0.0012361, ...
    'TemperatureBias',0.34907, ...
    'TemperatureScaleFactor',0.02, ...
    'AccelerationBias',0.00017809, ...
    'ConstantBias',[0.3491,0.5,0]);

[accelReadings,gyroReadings, magReadings] = IMU(accNED,angVelNED,orientationNED);

figure(1)
hold on;
t = (0:(totalNumSamples-1))/fs;
subplot(3, 1, 1)
plot(t,accelReadings)
legend('X-axis','Y-axis','Z-axis')
ylabel('Acceleration (m/s^2)')
title('Accelerometer Readings')

subplot(3, 1, 2)
plot(t,magReadings)
legend('X-axis','Y-axis','Z-axis')
ylabel('Magnetic Field (\muT)')
xlabel('Time (s)')
title('Magnetometer Readings')

subplot(3, 1, 3);
plot(t, gyroReadings);
legend('X-axis','Y-axis','Z-axis')
ylabel('Angular Velocity (rad/s)')
xlabel('Time (s)')
title('Gyroscope Readings')

% data prepared

% no filtering
raw_data = zeros(length(gyroReadings), 1, "quaternion");
% simple linear Kalman filter
Q = 0.0001 * eye(4);
R = 0.5 * eye(4);
P = 0.01 * eye(4);

H = eye(4);
x = [1 0 0 0]'; % zero quaternion
u = zeros(1);

kalman_quat = zeros(length(gyroReadings), 1, 'quaternion');


for i=1:length(gyroReadings)
    %%% start of raw data processing
    acc = accelReadings(i, :);
    gyro = gyroReadings(i, :);
    mag = magReadings(i, :);

    % down is in the opposite direction of acc
    down = -acc;
    D = down / norm(down);

    % mag points in the direction of north / down
    % east is the cross product of D, mag
    mag = mag / norm(mag);
    E = cross(D, mag);
    E = E / norm(E);

    % north is the cross product of E and D
    N = cross(D, E);
    N = N / norm(N);

    dcm = [N', E', D']; % x is north, y is east and z is down
    a = quaternion(dcm2quat(-dcm)); % czemu tak?
    test = ecompass(acc, mag);
    raw_data(i) = a;

    %%% kalman filter

    norm_acc = acc / norm(acc);
    a = -gyro(3);
    b = -gyro(1);
    c = gyro(2);

    Omega = [0, -a, -b, -c;
        a, 0, c, -b;
        b, -c, 0, a;
        c, b, a, 0];
    F = eye(4) + (dt / 2) * Omega;
    G = [0; 0; 0; 0];

    ax = acc(1) / norm(acc);
    ay = acc(2) / norm(acc);
    theta = asin(ax);
    phi = asin(-ay / cos(theta));
    psi = 0; % can't be estimated

    tht2 = theta / 2;
    phi2 = asin(-ay / cos(theta));
    psi2 = psi / 2;

    z = [ cos(phi2)*cos(tht2)*cos(psi2) + sin(phi2)*...
        sin(tht2)*sin(psi2); sin(phi2)*cos(tht2)*...
        cos(psi2)-cos(phi2)*sin(tht2)*sin(psi2);
        cos(phi2)*sin(tht2)*cos(psi2) + sin(phi2)*...
        cos(tht2)*sin(psi2); cos(phi2)*cos(tht2)*sin(psi2)-...
        sin(phi2)*sin(tht2)*cos(psi2)];

    [P_a, x_a, K_g] = kf(F, G, Q, H, R, P, x, u, z);

    kalman_quat(i) = quaternion(x_a');
end

figure;
orientation_euler = eulerd(raw_data, 'ZYX', 'frame');
gt_euler = eulerd(orientationNED, 'ZYX', 'frame');
kalman_euler = eulerd(kalman_quat, 'ZYX', 'frame');


% Plotting for the first set of Euler angles
subplot(3, 1, 1);
hold on;
plot(t, orientation_euler(:, 1));
plot(t, gt_euler(:, 1), 'k');
plot(t, kalman_euler(:, 1), 'm');
title('Trajectory 1: Roll');
ylabel('Angle (degrees)');
xlabel('Time (s)');
legend("Computed", "Ground truth", "Kalman");

subplot(3, 1, 2);
hold on;
plot(t, orientation_euler(:, 2));
plot(t, gt_euler(:, 2), 'k');
plot(t, kalman_euler(:, 2), 'm');
title('Trajectory 1: Pitch');
ylabel('Angle (degrees)');
xlabel('Time (s)');
legend("Computed", "Ground truth", "Kalman");

subplot(3, 1, 3);
hold on;
plot(t, orientation_euler(:, 3));
plot(t, gt_euler(:, 3), 'k');
plot(t, kalman_euler(:, 3), 'm');
title('Trajectory 1: Yaw');
ylabel('Angle (degrees)');
xlabel('Time (s)');
legend("Computed", "Ground truth", "Kalman");


function [P_a, x_a, K_g] = kf(F, G, Q, H, R, P, x, u, z)
    % the model predicts a new x_m
    x_m = F * x + G * u;
    % the model predicts a new P
    P_m = F * P * transpose(F) + Q;

    x_b = x_m;
    P_b = P_m;

    % update (correction) step
    K_g = P_b * transpose(H) * inv(H * P_b * transpose(H) + R);
    x_a = x_b + K_g * (z - H * x_b);
    P_a = P_b - K_g * H * P_b;
end