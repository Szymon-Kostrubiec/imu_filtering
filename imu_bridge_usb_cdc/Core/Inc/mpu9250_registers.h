#pragma once

// MPU-9250 Register Addresses
#define MPU9250_ADDR         0x68 // MPU-9250 address (check if AD0 is high or low)
#define PWR_MGMT_1           0x6B
#define GYRO_CONFIG          0x1B
#define CONFIG               0x1A
#define ACCEL_CONFIG         0x1C
#define ACCEL_CONFIG2        0x1D
#define WHO_AM_I             0x75

// Accelerometer Full Scale Range (±2, ±4, ±8, ±16 g)
#define ACCEL_FS_SEL_2G      0x00

// Gyroscope Full Scale Range (±250, ±500, ±1000, ±2000 degrees/second)
#define GYRO_FS_SEL_250      0x00
#define GYRO_FS_SEL_500      0x08
#define GYRO_FS_SEL_1000     0x10
#define GYRO_FS_SEL_2000     0x18

// CONFIG register settings for DLPF
#define DLPF_BYPASS          0x01 // Set DLPF_CFG to 0x01 for 3600 Hz bandwidth

// ACCEL_CONFIG2 settings for no filtering and desired sample rate
#define ACCEL_FCHOICE_B      0x08
#define A_DLPF_CFG           0x00 // No filtering

// MPU-9250 Register Addresses
#define MPU9250_ADDR         0x68  // MPU-9250 address (check if AD0 is high or low)
#define INT_PIN_CFG          0x37
#define I2C_MST_CTRL         0x24
#define USER_CTRL            0x6A
#define I2C_SLV0_ADDR        0x25
#define I2C_SLV0_REG         0x26
#define I2C_SLV0_CTRL        0x27
#define EXT_SENS_DATA_00     0x49

// AK8963 Register Addresses and Modes
#define AK8963_ADDR          0x0C  // AK8963 address
#define AK8963_WHO_AM_I      0x00  // should return 0x48
#define AK8963_CNTL1         0x0A
#define AK8963_CNTL2         0x0B
#define AK8963_ASAX          0x10  // Fuse ROM X-axis sensitivity adjustment value
#define AK8963_ASAY          0x11  // Fuse ROM Y-axis sensitivity adjustment value
#define AK8963_ASAZ          0x12  // Fuse ROM Z-axis sensitivity adjustment value

// Magnetometer Mode
#define MAG_MODE_POWER_DOWN  0x00
#define MAG_MODE_SINGLE      0x01
#define MAG_MODE_CONT1       0x02  // 8 Hz
#define MAG_MODE_CONT2       0x06  // 100 Hz
#define MAG_MODE_FUSE_ROM    0x0F
#define MAG_MODE_16BIT       0x10  // Output bit setting (0: 14bit, 1: 16bit)

// Gyroscope data register addresses
#define GYRO_XOUT_H    0x43
#define GYRO_XOUT_L    0x44
#define GYRO_YOUT_H    0x45
#define GYRO_YOUT_L    0x46
#define GYRO_ZOUT_H    0x47
#define GYRO_ZOUT_L    0x48

// Accelerometer data register addresses
#define ACCEL_XOUT_H    0x3B
#define ACCEL_XOUT_L    0x3C
#define ACCEL_YOUT_H    0x3D
#define ACCEL_YOUT_L    0x3E
#define ACCEL_ZOUT_H    0x3F
#define ACCEL_ZOUT_L    0x40

// Magnetometer data register addresses
#define AK8963_ST1       0x02  // Data ready status bit 0
#define AK8963_XOUT_L    0x03
#define AK8963_XOUT_H    0x04
#define AK8963_YOUT_L    0x05
#define AK8963_YOUT_H    0x06
#define AK8963_ZOUT_L    0x07
#define AK8963_ZOUT_H    0x08
#define AK8963_ST2       0x09  // Data read end bit 0
