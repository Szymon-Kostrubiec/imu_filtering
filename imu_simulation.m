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

save imu_simulated.mat t accelReadings gyroReadings magReadings angVelBody