import serial
import struct
import numpy as np
import pandas as pd
from time import time

port = serial.Serial("COM5", baudrate=500000, timeout=3.0)
accel_readings = np.empty((300000, 4), float)
accel_readings_index = 0
gyro_readings = np.empty((300000, 4), float)
gyro_readings_index = 0

acc = False
try:
    while True:
        while True:
            a = port.read()
            if a == b'$':
                acc = False
                break
            if a == b'#':
                acc = True
                break
        bytes = port.read(13)
        z = len(bytes)
        if acc:
            floats = struct.unpack('3f', bytes[:12])
            print(floats)
            accel_readings[accel_readings_index][1:] = floats
            accel_readings[accel_readings_index][0] = time()
            accel_readings_index += 1
        else:
            floats = struct.unpack('3f', bytes[:12])
            print(floats)
            gyro_readings[gyro_readings_index][1:] = floats
            gyro_readings[gyro_readings_index][0] = time()
            gyro_readings_index += 1
        
        if accel_readings_index == 300000:
            break
        if gyro_readings_index == 300000:
            break

except KeyboardInterrupt:
    pass
finally:
    port.close()
    with open('accel_readings.csv', 'w') as f:
        pd.DataFrame(accel_readings).to_csv(f, header=False, index=False)
    with open('gyro_readings.csv', 'w') as f:
        pd.DataFrame(gyro_readings).to_csv(f, header=False, index=False)