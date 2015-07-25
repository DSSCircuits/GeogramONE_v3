void MAX17043init()
{
	MAX17043sleep(true);
	MAX17043quickStart();
	MAX17043setAlertLevel(EEPROM.read(BATTERYLOWLEVEL));
	MAX17043clearAlertFlag();
	return;
}

void MAX17043quickStart()
{	
	uint8_t fgData[2] = {0x40,0x00}; //MSB is transmitted first
	I2c.write(FUELGAUGE,0x06,fgData,2);
}

void MAX17043setAlertLevel(uint8_t batteryInterruptValue)   //saves as actual percentage
{
	uint8_t configRegister[2] = {0,0};
	batteryInterruptValue -= 32;
	I2c.read(FUELGAUGE,0x0C,2,configRegister);
	batteryInterruptValue &= 0x1F;  // set 3msb to zero
	configRegister[1] &= 0xE0;  // zero battery level  , was originally FE
	configRegister[1] |= batteryInterruptValue; //set new battery level
	I2c.write(FUELGAUGE,0x0C,configRegister,2);
}
/*
void MAX17043configureBatteryAlert(uint8_t setAlert)
{
	if(!setAlert) //we don't want to use the low battery alert function
	{
		pinMode(FUELGAUGEPIN,INPUT);
		digitalWrite(FUELGAUGEPIN,LOW);  //set pin to high impedance
	}
	if(setAlert) //we do want to use the low battery alert function
	{
		pinMode(FUELGAUGEPIN,INPUT);
		digitalWrite(FUELGAUGEPIN,HIGH);
	}
}
*/
uint8_t MAX17043clearAlertFlag()
{
	uint8_t configRegister[2] = {0,0};
	I2c.read(FUELGAUGE,0x0C,2,configRegister);
	configRegister[1] &= 0xDF;
	return(I2c.write(FUELGAUGE,0x0C,configRegister,2));
}

uint8_t MAX17043getAlertFlag()
{
	uint8_t configRegister[2] = {0,0};
	I2c.read(FUELGAUGE,0x0C,2,configRegister);
	configRegister[1] &= 0xDF;
	return((configRegister[1] &= 0xDF) >> 5);
}

uint16_t MAX17043getBatterySOC()
{
	uint16_t batterySOC = 0;
	I2c.read(FUELGAUGE,0x04,2);
	for(uint8_t i = 0;i < 2;i++)
	{ 
		batterySOC <<= 8;
		batterySOC |= I2c.receive();
	}
	return(map(batterySOC,0x0000,0x6400,0,10000));
}

void MAX17043sleep(bool sleepWake)
{
	uint8_t configRegister[2] = {0,0};
	I2c.read(FUELGAUGE,0x0C,2,configRegister);
	if(!sleepWake)
		configRegister[1] |= 0x80;
	else
		configRegister[1] &= 0x7F;
	I2c.write(FUELGAUGE,0x0C,configRegister,2);
}

