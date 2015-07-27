void setEeprom()
{
	char *ptr = NULL;
	char *str = NULL;
	ptr = strtok_r(smsData.smsCmdString,".",&str);
	uint16_t eepAdd = atoi(ptr);
	switch(eepAdd)
	{
	/**** uint8_t  ****/
		case IOSTATE0:
			{
				ptr = strtok_r(NULL,".",&str);
				uint8_t ptrEp = atoi(ptr);
				if((ptrEp < 3) || (ptrEp == 4))
				{
					EEPROM.write(eepAdd,ptrEp);
					configureIoPin(4,ptrEp);
					return;
				}
				if(ptrEp == 6)
					singlePulse(4);
				if(ptrEp == 7)
					doublePulse(4);
				if(ptrEp == 5)
					digitalReadPin = 4;
			}
			break;
		case IOSTATE1:
			{
				ptr = strtok_r(NULL,".",&str);
				uint8_t ptrEp = atoi(ptr);
				if((ptrEp < 3) || (ptrEp == 4))
				{
					EEPROM.write(eepAdd,ptrEp);
					configureIoPin(10,ptrEp);
					return;
				}
				if(ptrEp == 6)
					singlePulse(10);
				if(ptrEp == 7)
					doublePulse(10);
				if(ptrEp == 5)
					digitalReadPin = 10;
			}
			break;
		case IOSTATE2: case IOSTATE3: case IOSTATE4:
			{
				ptr = strtok_r(NULL,".",&str);
				uint8_t ptrEp = atoi(ptr);
				uint8_t pinNumber = eepAdd - IOSTATE2 + 1;
				if(ptrEp < 4)
				{
					EEPROM.write(eepAdd,ptrEp);
					configureIoPin(pinNumber,ptrEp);
					return;
				}
				if((ptrEp == 5) && (EEPROM.read(eepAdd) == 3))
					analogReadPin = pinNumber;
				else
					digitalReadPin = pinNumber + 14;
				if(ptrEp == 6)
					singlePulse(pinNumber + 14);
				if(ptrEp == 7)
					doublePulse(pinNumber + 14);
			}
			break;
		case IOSTATE5:
			analogReadPin = 6;
			break;
	/**** uint8_t  ****/
		case IOSINGLEPULSETIME: case IODOUBLEPULSETIME1: case IODOUBLEPULSETIME2: case IODOUBLEPULSETIME3: 
		case RETURNADDCONFIG: case BATTERYLOWLEVEL: case BMA0X0F: case BMA0X10: case BMA0X11:  
		case BMA0X16: case BMA0X17: case BMA0X19: case BMA0X1A: case BMA0X1B: case BMA0X20: case BMA0X21: 
		case BMA0X25: case BMA0X26: case BMA0X27: case BMA0X28: case ENGMETRIC: case SLEEPTIMECONFIG:
		case BREACHSPEED: case BREACHREPS: case SPEEDHYST: case UDPPOWERPROFILE: case SMSPOWERPROFILE:
		case UDPSPEEDBAT: case UDPSPEEDPLUG: case SMSSPEEDBAT: case SMSSPEEDPLUG:
 			ptr = strtok_r(NULL,".",&str);
			EEPROM.write(eepAdd,(uint8_t)atoi(ptr));
			if((eepAdd >= BMA0X0F) && (eepAdd <= BMA0X28))
			{
				BMA250configureMotion();
				BMA250configureInterrupts();
			}
			break;
	/**** int_8  ****/
		case TIMEZONE:
			ptr = strtok_r(NULL,".",&str);
			EEPROM.write(eepAdd,(int8_t)atoi(ptr));
			break;
	/**** uint16_t  ****/
		case SPEEDLIMIT: case GPRS_PORT:
			ptr = strtok_r(NULL,".",&str);
			EEPROM_writeAnything(eepAdd,(uint16_t)(atoi(ptr)));
			break;
	/**** unsigned long  ****/ 
		case SLEEPTIMEON: case SLEEPTIMEOFF: case SMSSENDINTERVALBAT: case SMSSENDINTERVALPLUG: 
		case UDPSENDINTERVALBAT: case UDPSENDINTERVALPLUG:
			ptr = strtok_r(NULL,".",&str);
			EEPROM_writeAnything(eepAdd,(unsigned long)(atol(ptr)));
			break;
	/**** long  ****/
		case RADIUS1: case RADIUS2: case RADIUS3:
			{
				ptr = strtok_r(NULL,".",&str);
				if(ptr[0] == '*')
				{
					long latLonSigned = (long)(atof(lastValid.latitude) *10000);
					if(lastValid.ns == 'S')
						latLonSigned *= -1;
					EEPROM_writeAnything(eepAdd + 4, latLonSigned);
					latLonSigned = (long)(atof(lastValid.longitude) *10000);
					if(lastValid.ew == 'W')
						latLonSigned *= -1;
					EEPROM_writeAnything(eepAdd + 8, latLonSigned);
					EEPROM_writeAnything(eepAdd,(long)(atol(ptr + 1)));
				}
				else
					EEPROM_writeAnything(eepAdd,(long)(atol(ptr)));
			}
			break;
	/**** long  ****/
		case LATITUDE1: case LATITUDE2: case LATITUDE3: case LONGITUDE1: case LONGITUDE2: case LONGITUDE3:
			ptr = strtok_r(NULL,".",&str);
			EEPROM_writeAnything(eepAdd,(long)(atol(ptr)));
			break;
	/**** string length 4 characters...not including terminating null ****/
		case PINCODE:
			ptr = strtok_r(NULL,".",&str);
			writeEEPROM(ptr,eepAdd,4);
			break;
	/**** string length 35 characters...not including terminating null ****/
		case HTTP1: case GPRS_APN: case GPRS_HOST:
			ptr = strtok_r(NULL,"*",&str); 
			writeEEPROM(ptr,eepAdd,35);
			break;
	/**** string length 15 characters...not including terminating null ****/
		case IMEI: case SMSADDRESS: case MOTIONMSG: case BATTERYMSG: case FENCE1MSG: case FENCE2MSG: case FENCE3MSG:
		case SPEEDMSG: case MAXSPEEDMSG: case GEOGRAMONEID: case D4MSG: case D10MSG: case UDP_HEADER:
			ptr = strtok_r(NULL,"*",&str);
			writeEEPROM(ptr,eepAdd,15);
			break;
	}
}

void writeEEPROM(char *eptr, uint16_t eAddress, uint8_t eSize)
{
	for(uint8_t e = 0; e < eSize; e++)
	{
		EEPROM.write(eAddress + e,eptr[e]);
		if(eptr[e] == NULL)
			break;
	}
	EEPROM.write(eAddress + eSize,'\0'); 
}
      
void getEeprom()
{
	char *ptr = NULL;
	char *str = NULL;
	ptr = strtok_r(smsData.smsCmdString,".",&str);
	uint16_t eepAdd = atoi(ptr);
	if(!startSMSSend(1))
	{
		switch(eepAdd)
		{
			//uint8_t
			case IOSINGLEPULSETIME: case IODOUBLEPULSETIME1: case IODOUBLEPULSETIME2: case IODOUBLEPULSETIME3: 
			case RETURNADDCONFIG: case BATTERYLOWLEVEL: case BMA0X0F: case BMA0X10: case BMA0X11: case BMA0X16: 
			case BMA0X17: case BMA0X19: case BMA0X1A: case BMA0X1B: case BMA0X20: case BMA0X21: case BMA0X25:
			case BMA0X26: case BMA0X27: case BMA0X28: case ENGMETRIC: case SLEEPTIMECONFIG:
			case BREACHSPEED: case BREACHREPS: case SPEEDHYST: case UDPPOWERPROFILE: case SMSPOWERPROFILE:
			case UDPSPEEDBAT: case UDPSPEEDPLUG: case SMSSPEEDBAT: case SMSSPEEDPLUG:
			case IOSTATE0: case IOSTATE1: case IOSTATE2: case IOSTATE3: case IOSTATE4: case IOSTATE5:
				GSM.println((uint8_t)EEPROM.read(eepAdd),DEC);
				break;
			//int8_t
			case TIMEZONE:
				GSM.println((int8_t)EEPROM.read(eepAdd),DEC);
				break;
			//uint16_t
			case SPEEDLIMIT: case GPRS_PORT:
				{
					uint16_t nonByte;
					EEPROM_readAnything(eepAdd,nonByte);
					GSM.println(nonByte,DEC);
				}
				break;
			//unsigned long 
			case SLEEPTIMEON: case SLEEPTIMEOFF: case SMSSENDINTERVALBAT: case SMSSENDINTERVALPLUG: 
			case UDPSENDINTERVALBAT: case UDPSENDINTERVALPLUG:
				{
					unsigned long nonByte;
					EEPROM_readAnything(eepAdd,nonByte);
					GSM.println(nonByte,DEC);
				}
				break;
			// long
			case LATITUDE1: case LATITUDE2: case LATITUDE3: 
			case LONGITUDE1: case LONGITUDE2: case LONGITUDE3:
			case RADIUS1: case RADIUS2: case RADIUS3:
				{
					long nonByte;
					EEPROM_readAnything(eepAdd,nonByte);
					GSM.println(nonByte,DEC);
				}
				break;
			case PINCODE:
			case SMSADDRESS: case MOTIONMSG: case BATTERYMSG: case FENCE1MSG: case FENCE2MSG: case FENCE3MSG: 
			case SPEEDMSG: case MAXSPEEDMSG: case GEOGRAMONEID: case D4MSG: case D10MSG: case HTTP1: 
			case GPRS_APN: case IMEI: case GPRS_HOST: case UDP_HEADER:
				printEEPROM(eepAdd);
				break;
			default:
				GSM.println("Invalid EEPROM Address");
				break;
		}
		sim900.sendSMS();
	}
	sim900.gsmSleepMode(2);
}	
