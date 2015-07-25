#if USE_GEOFENCE
void geoFence()
{
	if(lastValid.updated & 0x02)
	{
		lastValid.updated &= ~(0x02);
		geoFenceCheck(0, &f1, &f1Alarm);
		geoFenceCheck(1, &f2, &f2Alarm);
		geoFenceCheck(2, &f3, &f3Alarm);
	}
}

void geoFenceCheck(uint8_t fNumber, uint8_t *fRep, uint8_t *fenceAlarm)
{
	bool overSpeed = false;
	bool gfBreach = true;
	bool inOut = true;
	long fRadius;
	if(*fenceAlarm == 0x01) //check if alert needs to be sent
	{
		if(!startSMSSend(1))
		{
			printEEPROM(FENCE1MSG + (fNumber * 16));
			if(!sim900.sendSMS())
				*fenceAlarm = 0x02;		
		}
		sim900.gsmSleepMode(2);
		return;
	}
	if((((lastValid.speedKPH) >= EEPROM.read(BREACHSPEED)) && EEPROM.read(ENGMETRIC))||(((lastValid.speedMPH) >= EEPROM.read(BREACHSPEED)) && !(EEPROM.read(ENGMETRIC))))
		overSpeed = true;
	EEPROM_readAnything((RADIUS1 + (fNumber * 12)),fRadius);
	if( ((fRadius) && overSpeed) ||  (*fenceAlarm == 0x02))
	{
		if(fRadius >= 0)
			inOut = false;
		gfBreach = calculateFenceDiameter(fNumber, fRadius); //0 = fence 1
		if(*fenceAlarm == 0x02) // check to see if we are watching reset time reps
			gfBreach = !gfBreach; // invert because we are seeing how long back in the fence area
		if(gfBreach ^ inOut)
		{
			(*fRep)--;
			if(*fRep)
				return;
			if(*fenceAlarm == 0x02) //check to see if we were counting down to reset fence monitoring
				*fenceAlarm = 0x00; //reset fence to start checking again
			else
				*fenceAlarm = 0x01; //fence breached ready to send alert
		}
		*fRep = EEPROM.read(BREACHREPS); //fence breach or reset condition not met, reset counter
	}
}


bool calculateFenceDiameter(uint8_t _fNumber, long _fRadius)
{
	long fLatitude;
	long fLongitude;
	EEPROM_readAnything((LATITUDE1 + (_fNumber * 12)),fLatitude);
	EEPROM_readAnything((LONGITUDE1 + (_fNumber * 12)),fLongitude);
	float ToRad = PI / 180.0;
	float R = 6378.1; // radius earth in Km;
	float lLat = ((uint16_t)(atoi(lastValid.latitude)/100)) + (atof(lastValid.latitude + 2) / 60.0);
	float lLon = ((uint16_t)(atoi(lastValid.longitude)/100)) + (atof(lastValid.longitude + 3) / 60.0);
	if(lastValid.ns == 'S')
		lLat *= -1.0;
	if(lastValid.ew == 'W')
		lLon *= -1.0;
	float dLat = ((((fLatitude%1000000)/600000.0) + (fLatitude/1000000)) - (lLat)) * ToRad;
	float dLon = ((((fLongitude%1000000)/600000.0) + (fLongitude/1000000)) - (lLon)) * ToRad;
	float a = sin(dLat/2) * sin(dLat/2) + cos((lLat) * ToRad) * cos((lLat) * ToRad) * sin(dLon/2) * sin(dLon/2);
	float c = 2 * atan2(sqrt(a), sqrt(1 - a));
	unsigned long d = (unsigned long)(R * c * 1000UL);
	if(!(EEPROM.read(ENGMETRIC)))
		d *= 3.2808; //meters to feet
	if(d >= abs(_fRadius))
		return true;
	else
		return false;
}
#endif
