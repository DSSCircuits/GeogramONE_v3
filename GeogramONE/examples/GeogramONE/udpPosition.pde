#if USE_UDP
uint8_t udpPosition()
{
	static bool sendOK = false;
	if(!sendOK)	
	{
		GSM.println("AT+CGATT?");
		if(!sim900.confirmAtCommand(": 0",3000))
		{
			sim900.confirmAtCommand("OK",500);
			if(!sim900.signalQuality())
				return 6;
			if(!sim900.checkNetworkRegistration())
			{
				GSM.println("AT+CGATT=1");	
				if(sim900.confirmAtCommand("OK",10000) == 1) //if ERROR, need to reboot GSM module
				{
					static unsigned long resetGSM = millis();
					if((millis() - resetGSM) >= 300000) //if more than 5 minutes reboot GSM module
					{
						sim900.rebootGSM();
						gsmPowerStatus = true;
						resetGSM = millis();
					}
				}
			}
			else
				return 7;
		}
		uint8_t cStatus = sim900.cipStatus();
		switch(cStatus)
		{
			case 0:
				GSM.print("AT+CSTT=\"");
				printEEPROM(GPRS_APN);
				GSM.println("\"");
				if(sim900.confirmAtCommand("OK",3000))
					return 2;
			case 1:
				GSM.println("AT+CIICR");
				if(sim900.confirmAtCommand("OK",5000))
					return 2;
			case 2:
			//	return; //might need to put return back in
			case 3:
				GSM.println("AT+CIFSR");
				if(sim900.confirmAtCommand(".",2000) == 1)
					return 2;
				sim900.confirmAtCommand("\r\n",100);
			case 4:
			{
				GSM.print("AT+CIPSTART=\"UDP\",\""); 
				printEEPROM(GPRS_HOST);
				GSM.print("\",\"");
				uint16_t portNumber = 0;
				EEPROM_readAnything(GPRS_PORT,portNumber);
				GSM.print(portNumber,DEC);
				GSM.println("\"");
				if(sim900.confirmAtCommand("T OK",2000))
					return 2;
			}
			case 5:
				break; //might need to change to return because of transition between 5 and 6
			case 6:
				break;
			case 7:
			case 8:
			case 9:
				GSM.println("AT+CIPSHUT");
				sim900.confirmAtCommand("OK",3000);
				return 2;
			default:
				return 2;
		}
	}
	if(EEPROM.read(IMEI) == '*')
	{
		char imei[16];
		sim900.getIMEI(imei);
		writeEEPROM(imei,IMEI,15);
	}
	GSM.println("AT+CIPSEND");
	if(!sim900.confirmAtCommand(">",3000))
	{
		geoUDP();
		GSM.println((char)0x1A);
		if(sim900.confirmAtCommand("OK\r\n",3000))
		{
			sendOK = false;
			return 2;
		}
		sendOK = true;
		return 0;
	}
	else
	{
		sendOK = false;
		return 2;
	}
}

void geoUDP()
{
	printEEPROM(IMEI);
	printEEPROM(UDP_HEADER);
	if(lastValid.day < 10)
		GSM.print("0");
	GSM.print(lastValid.day,DEC);
	if(lastValid.month < 10)
		GSM.print("0");
	GSM.print(lastValid.month,DEC);
	GSM.print(lastValid.year,DEC);
	GSM.print(";");
	if(lastValid.hour < 10)
		GSM.print("0");
	GSM.print(lastValid.hour,DEC);
	if(lastValid.minute < 10)
		GSM.print("0");
	GSM.print(lastValid.minute,DEC);
	if(lastValid.second < 10)
		GSM.print("0");
	GSM.print(lastValid.second,DEC);	
	GSM.print(";");
	GSM.print(lastValid.latitude);
	GSM.print(";");
	GSM.print(lastValid.ns);
	GSM.print(";");
	GSM.print(lastValid.longitude);
	GSM.print(";");
	GSM.print(lastValid.ew);
	GSM.print(";");
	GSM.print(lastValid.speedKPH);
	GSM.print(";");
	GSM.print(lastValid.course);
	GSM.print(";");
	GSM.print(lastValid.altitudeM);
	GSM.print(";");
	GSM.println(lastValid.satellitesUsed);
}
#endif