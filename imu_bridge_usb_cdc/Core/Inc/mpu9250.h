#pragma once

#include "types.h"

void mpu9250_init(float mag_adjustment[3]);

void read_gyro(i16 gyro[3]);

void read_acc(i16 acc[3]);

u8 read_mag(i16 mag[3]);
