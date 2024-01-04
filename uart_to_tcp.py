import serial
import struct
import socket

port = serial.Serial("COM5", baudrate=500000, timeout=3.0)

udp_host = 'localhost'
udp_port = 5555
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

try:
    
    while True:
        cnt = 0
        while cnt < 4:
            a = port.read()
            if a == b'$':
                cnt += 1
            else:
                cnt = 0
        rcv = port.read(40)
        floats = struct.unpack('10f', rcv)
        udp_socket.sendto(floats, (udp_host, udp_port))
        
        print(floats)
except KeyboardInterrupt:
    pass
finally:
    port.close()
    udp_socket.close()