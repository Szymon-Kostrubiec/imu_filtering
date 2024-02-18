import serial
import struct
import sys
import numpy as np
import pandas as pd

port = serial.Serial("COM5", baudrate=500000, timeout=9.0)
accel_readings = np.empty((300000, 3), float)
gyro_readings = np.empty((300000, 3), float)
mag_readings = np.empty((300000, 3), float)
readings_index = 0
max_readings = 10000

# if len(sys.argv) > 1:
#     try:
#         max_readings = int(sys.argv[1])
#     except ValueError:
#         print("Provided argument is not a number.")
#         exit(1)
# else:
#     print("Specify the desired number of samples to collect.")

try:
    while True:
        while True:
            # wait for start of packet
            a = port.read(1)
            print(a)
            if a == b'$':
                break
        print('start') 
        # read the rest of the packet
        recv = port.read(36)
        print('read')
        floats = struct.unpack('9f', recv)
        print(floats)
        accel_readings[readings_index] = floats[:3]
        gyro_readings[readings_index] = floats[3:6]
        mag_readings[readings_index] = floats[6:]
        readings_index += 1

        if readings_index >= max_readings:
            break

except KeyboardInterrupt:
    pass
finally:
    port.close()
    with open('accel_readings.csv', 'w') as f:
        pd.DataFrame(accel_readings).to_csv(f, header=False, index=False)
    with open('gyro_readings.csv', 'w') as f:
        pd.DataFrame(gyro_readings).to_csv(f, header=False, index=False)
    with open('mag_readings.csv', 'w') as f:
        pd.DataFrame(mag_readings).to_csv(f, header=False, index=False)