#include "mpu9250.h"

#include "gpio.h"
#include "spi.h"

#include <assert.h>

#include "mpu9250_registers.h"

static const u32 timeout = 10;

static u8 spi_read(u8 reg);

static void spi_write(u8 reg, u8 data);

static void ak8963_write(u8 reg, u8 data);

static u8 ak8963_read(u8 reg);

u8 asa[3] = {72, 72, 72};
static void init_ak8963();

void mpu9250_init(float mag_adjustment[3]) {
	spi_write(PWR_MGMT_1, 0x00); // clear sleep bit
	spi_write(GYRO_CONFIG, GYRO_FS_SEL_250);

	u8 who_ami_i = spi_read(WHO_AM_I);
	assert(who_ami_i == 0x71);

	// set gyro to 3.6 kHz, no lpf
	spi_write(CONFIG, DLPF_BYPASS);

	spi_write(ACCEL_CONFIG, ACCEL_FS_SEL_2G);

	// set accelerometer to 1.13 kHz, no lpf
	spi_write(ACCEL_CONFIG2, ACCEL_FCHOICE_B | A_DLPF_CFG);

	mag_adjustment[0] = (asa[0] / 256 + 0.5) * 0.15;
	mag_adjustment[1] = (asa[1] / 256 + 0.5) * 0.15;
	mag_adjustment[2] = (asa[2] / 256 + 0.5) * 0.15;

	init_ak8963();
}

void read_gyro(i16 gyro[3]) {
	u8 data[6];

	data[0] = spi_read(GYRO_XOUT_H);
	data[1] = spi_read(GYRO_XOUT_L);
	data[2] = spi_read(GYRO_YOUT_H);
	data[3] = spi_read(GYRO_YOUT_L);
	data[4] = spi_read(GYRO_ZOUT_H);
	data[5] = spi_read(GYRO_ZOUT_L);

	gyro[0] = (data[0] << 8) | data[1];
	gyro[1] = (data[2] << 8) | data[3];
	gyro[2] = (data[4] << 8) | data[5];
}

void read_acc(i16 acc[3]) {
	u8 data[6];

	data[0] = spi_read(ACCEL_XOUT_H);
	data[1] = spi_read(ACCEL_XOUT_L);
	data[2] = spi_read(ACCEL_YOUT_H);
	data[3] = spi_read(ACCEL_YOUT_L);
	data[4] = spi_read(ACCEL_ZOUT_H);
	data[5] = spi_read(ACCEL_ZOUT_L);

	acc[0] = (data[0] << 8) | data[1];
	acc[1] = (data[2] << 8) | data[3];
	acc[2] = (data[4] << 8) | data[5];
}

u8 read_mag(i16 mag[3]) {
	u8 status = ak8963_read(AK8963_ST1);

	if (status & 0x01) {
		u8 data[6];

		data[0] = ak8963_read(AK8963_XOUT_L);
		data[1] = ak8963_read(AK8963_XOUT_H);
		data[2] = ak8963_read(AK8963_YOUT_L);
		data[3] = ak8963_read(AK8963_YOUT_H);
		data[4] = ak8963_read(AK8963_ZOUT_L);
		data[5] = ak8963_read(AK8963_ZOUT_H);
		u8 magnetic_overflow =  ak8963_read(AK8963_ST2);

		if (!(magnetic_overflow & 0x08)) {
			mag[0] = (data[1] << 8) | data[0];
			mag[1] = (data[3] << 8) | data[2];
			mag[2] = (data[5] << 8) | data[4];
		}
	} else {
		return 0;
	}

	return 1;
}

static u8 spi_read(u8 reg) {
	reg |= 0x80;
	u8 tx_data = reg;
	u8 rx_data;

	HAL_StatusTypeDef status;

	HAL_GPIO_WritePin(SPI1_SSEL_GPIO_Port, SPI1_SSEL_Pin, RESET);
	status = HAL_SPI_Transmit(&hspi1, &tx_data, 1, timeout);
	status |= HAL_SPI_Receive(&hspi1, &rx_data, 1, timeout);
	HAL_GPIO_WritePin(SPI1_SSEL_GPIO_Port, SPI1_SSEL_Pin, SET);

	assert(status == HAL_OK);

	return rx_data;
}

static void spi_write(u8 reg, u8 data) {
	u8 tx_data[] = {reg, data};

	HAL_StatusTypeDef status;

	HAL_GPIO_WritePin(SPI1_SSEL_GPIO_Port, SPI1_SSEL_Pin, RESET);
	status = HAL_SPI_Transmit(&hspi1, &tx_data, 2, timeout);
	HAL_GPIO_WritePin(SPI1_SSEL_GPIO_Port, SPI1_SSEL_Pin, SET);

	assert(status == HAL_OK);
}
//void MPU9250_WriteAK8963(uint8_t reg, uint8_t data) {
//    MPU9250_WriteSPI(I2C_SLV0_ADDR, 0x0C);  // Write to AK8963
//    MPU9250_WriteSPI(I2C_SLV0_REG, reg);
//    MPU9250_WriteSPI(I2C_SLV0_CTRL, 0x81);  // Enable writing and read one byte
//    MPU9250_WriteSPI(EXT_SENS_DATA_00, data);
//}
//
//uint8_t MPU9250_ReadAK8963(uint8_t reg) {
//    MPU9250_WriteSPI(I2C_SLV0_ADDR, 0x8C);  // Read from AK8963
//    MPU9250_WriteSPI(I2C_SLV0_REG, reg);
//    MPU9250_WriteSPI(I2C_SLV0_CTRL, 0x81);  // Enable reading and read one byte
//    return MPU9250_ReadSPI(EXT_SENS_DATA_00);
//}

static void ak8963_write(u8 reg, u8 data) {
	spi_write(I2C_SLV0_ADDR, 0x0c); // write to ak8963
	spi_write(I2C_SLV0_REG, reg);
	spi_write(I2C_SLV0_CTRL, 0x81);
	spi_write(EXT_SENS_DATA_00, data); // enable write, read one byte
}

static u8 ak8963_read(u8 reg) {
	spi_write(I2C_SLV0_ADDR, 0x8c); // read from ak8963
	spi_write(I2C_SLV0_REG, reg);
	spi_write(I2C_SLV0_CTRL, 0x81); // enable read, read one byte
	return spi_read(EXT_SENS_DATA_00);
}

static void init_ak8963() {

	spi_write(USER_CTRL, 0x20);
	spi_write(I2C_MST_CTRL, 0x0d);

//	 reset ak8963
	ak8963_write(AK8963_CNTL2, 0x01);
	HAL_Delay(50);

	u8 id = ak8963_read(0x0);
	assert(id == 0x48);

	// set continuous measurement mode 2
	HAL_Delay(100);
	HAL_Delay(20);
	ak8963_write(AK8963_CNTL1, 0x16);
	HAL_Delay(100);

	u8 mode = ak8963_read(AK8963_CNTL1);
}
