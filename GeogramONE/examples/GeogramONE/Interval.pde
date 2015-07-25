void smsTimerMenu()
{
	static unsigned long smsTimer = millis();
	if((millis() - smsTimer) >= (smsInterval*1000))
	{
		bool speedExceeded = false;
		smsPowerProfile &= 0x03;
		if(EEPROM.read(ENGMETRIC))
		{
			if(lastValid.speedKPH >= smsPowerSpeed)
				speedExceeded = true;
		}
		else
		{
			if(lastValid.speedMPH >= smsPowerSpeed)
				speedExceeded = true;
		}
		if( (!smsPowerProfile) || ((move & 0x04) && (smsPowerProfile & 0x01))  ||  ((speedExceeded) && (smsPowerProfile & 0x02)) )
		{
			smsPosStatus = 0x01;
			move &= ~(0x04);
		}
		smsTimer = millis();
	}
}

void udpTimerMenu()
{
	static unsigned long udpTimer = millis();
	if((millis() - udpTimer) >= (udpInterval*1000))
	{
		bool speedExceeded = false;
		udpPowerProfile &= 0x03;
		if(EEPROM.read(ENGMETRIC))
		{
			if(lastValid.speedKPH >= udpPowerSpeed)
				speedExceeded = true;
		}
		else
		{
			if(lastValid.speedMPH >= udpPowerSpeed)
				speedExceeded = true;
		}	
		if( (!udpPowerProfile)  ||  ((move & 0x02) && (udpPowerProfile & 0x01))  ||  ((speedExceeded) && (udpPowerProfile & 0x02)) )
		{
			udp |= 0x01;
			move &= ~(0x02);
		}
		udpTimer = millis();
	}
}

