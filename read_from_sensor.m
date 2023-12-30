clear; close all; clc;

u = udp('localhost', 5555);
u.InputBufferSize = 4096;
fopen(u);

try
    while true
        if u.BytesAvailable > 0
            data = fread(u, u.BytesAvailable);

            floats = typecast(uint8(data), 'single');
            floats
    end
catch ME
    disp(['Error', ME.message])
end

fclose(u);
delete(u);
