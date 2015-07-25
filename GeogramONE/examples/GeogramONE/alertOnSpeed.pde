#if USE_SPEED_ALERT
void alertOnSpeed() //speed monitoring mode
{
	uint16_t spdLimit;
	EEPROM_readAnything(SPEEDLIMIT,spdLimit);
	if(!spdLimit)
	{
		spdMonStatus = 0x00;
		return;
	}
	static uint16_t maxSpeed = 0;
	static uint8_t spdMonStatus = 0x01;
	uint16_t curSpeed;
	if(EEPROM.read(ENGMETRIC))
		curSpeed = lastValid.speedKPH;
	else
		curSpeed = lastValid.speedMPH;
	if((spdMonStatus == 0x01) && (curSpeed > spdLimit))
		spdMonStatus = 0x02;
	if(spdMonStatus == 0x02)
	{
		if(startSMSSend(1))
			return;
		printEEPROM(SPEEDMSG);
		GSM.println();
		geoSMS(0);
		if(sim900.sendSMS())
			return;
		maxSpeed = curSpeed;
		spdMonStatus = 0x03;
	}
	if(spdMonStatus == 0x03)
	{
		if(curSpeed > maxSpeed)
			maxSpeed = curSpeed;
		if(curSpeed <= (uint16_t)(spdLimit - EEPROM.read(SPEEDHYST)))
			spdMonStatus = 0x04;
	}
	if(spdMonStatus == 0x04)
	{
		if(startSMSSend(1))
			return;
		printEEPROM(MAXSPEEDMSG);
		GSM.println(maxSpeed);
		geoSMS(0);
		if(sim900.sendSMS())
			return;
		spdMonStatus = 0x01; 
		maxSpeed = 0;
		sim900.gsmSleepMode(2);
	}
}
#endif