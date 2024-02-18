clear; close all; clc;

acc_params = accelparams("MeasurementRange", 20, "Resolution", 2 / 2^16, ...
    "ConstantBias", [0.01, 0.02, 0.03], ...
    "AxesMisalignment", [10, 10, 10], ...
    "NoiseDensity", [0.05], ...
    "BiasInstability", 0.002, ...
    "RandomWalk", 0.004);

gyro_params = gyroparams("MeasurementRange", 250, ...
    "Resolution", 250 / 2^16, ...
    "ConstantBias", [1, 2, 3], ...
    "AxesMisalignment", [10, 10, 10], ...
    "NoiseDensity", [0.1, 0.1, 0.1], ...
    "BiasInstability", 0.002, ...
    "RandomWalk", 0.004);

mag_params = magparams("MeasurementRange", 4800, "Resolution", 4800 / 2^14, ...
    "ConstantBias", [10, 20, 30], ...
    "AxesMisalignment", [3, 3, 3], ...
    "BiasInstability", [0.01, 0.01, 0.01], ...
    "NoiseDensity", [0.1, 0.1, 0.1], ...
    "RandomWalk", [0.01, 0.01, 0.01]);

IMU = imuSensor('accel-gyro-mag');
IMU.Accelerometer = acc_params;
IMU.Gyroscope = gyro_params;
IMU.Magnetometer = mag_params;
IMU.SampleRate = 1000;

numSamples = 1000;
acceleration = zeros(numSamples,3);
angularVelocity = zeros(numSamples,3);

[accelReading,gyroReading,magReading] = IMU(acceleration,angularVelocity);

t = (0:(numSamples-1))/IMU.SampleRate;
subplot(3,1,1)
plot(t,accelReading)
legend('X-axis','Y-axis','Z-axis')
title('Accelerometer Readings')
ylabel('Acceleration (m/s^2)')

subplot(3,1,2)
plot(t,gyroReading)
legend('X-axis','Y-axis','Z-axis')
title('Gyroscope Readings')
ylabel('Angular Velocity (rad/s)')

subplot(3,1,3)
plot(t,magReading)
legend('X-axis','Y-axis','Z-axis')
title('Magnetometer Readings')
xlabel('Time (s)')
ylabel('Magnetic Field (uT)')

writematrix(accelReading, 'acc.csv')
writematrix(gyroReading, 'gyro.csv')
writematrix(magReading, 'mag.csv')