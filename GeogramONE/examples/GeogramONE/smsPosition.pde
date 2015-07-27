void smsPosition()  //send coordinates
{
	sim900.gsmSleepMode(0);
	uint16_t geoDataFormat;
	uint8_t rssi = sim900.signalQuality();
	if(rssi)
	{
		if(!startSMSSend(3))
		{	
			geoSMS(rssi);
			if(!sim900.sendSMS())
				smsPosStatus = 0;
		}
	}
	sim900.gsmSleepMode(2);
}

void geoSMS(uint8_t rssi)
{
	GSM.print(lastValid.month,DEC);
	GSM.print("/");
	GSM.print(lastValid.day,DEC);
	GSM.print("/");
	GSM.print(lastValid.year,DEC);
	GSM.print(",");
	GSM.print(lastValid.hour,DEC);
	GSM.print(":");
	GSM.print(lastValid.minute,DEC);
	GSM.print(":");
	GSM.print(lastValid.second,DEC);
	GSM.print(",");
	if(EEPROM.read(ENGMETRIC))
		GSM.print(lastValid.speedKPH,DEC);
	else
		GSM.print(lastValid.speedMPH,DEC);
	GSM.print(",");
	GSM.print(lastValid.course,DEC);
	GSM.print(",");
	printEEPROM(GEOGRAMONEID);
	GSM.print(",");
	GSM.print(MAX17043getBatterySOC()/100,DEC);
	GSM.print("%");
	GSM.print(",");
	GSM.print(rssi,DEC);
	GSM.print(",");
	GSM.print(lastValid.satellitesUsed,DEC);
	GSM.print(",");
	if(!charge)
		GSM.println("BAT");
	else
		GSM.println("CHG");

	printEEPROM(HTTP1);
	if(lastValid.ns == 'S')
		GSM.print("-");
	GSM.print(lastValid.latitude[0]);
	GSM.print(lastValid.latitude[1]);
	GSM.print("+");
	GSM.print(lastValid.latitude + 2);
	GSM.print(",");
	if(lastValid.ew == 'W')
		GSM.print("-");
	GSM.print(lastValid.longitude[0]);
	GSM.print(lastValid.longitude[1]);
	GSM.print(lastValid.longitude[2]);
	GSM.print("+");
	GSM.println(lastValid.longitude + 3);
}