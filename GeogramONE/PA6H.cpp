#include "PA6H.h"

/*	CONSTRUCTOR	*/
PA6H::PA6H(HardwareSerial *ser)
{
	gpsSerial = ser;
}

void PA6H::init()
{
	resetAll();
}

void PA6H::resetAll()
{
	startNew = false; 
	sentenceID = 0x07;
}

uint8_t PA6H::getCoordinates(goCoord *lastKnown, int8_t _tZ)
{
	tZ = _tZ;
	if(!gpsSerial->available()) 
		return 2;  //no data in the buffer, safe to return
	unsigned long getGpsDataTime = millis();
	while((millis() - getGpsDataTime) < 45 )
	{
		if(!gpsSerial->available())
			continue;
		gpsField[charIndex] = gpsSerial->read();
		gpsField[charIndex+1] = '\0';
		if((gpsField[charIndex] != '$') && (!startNew))
			continue;
		switch(gpsField[charIndex])
		{
			case '$':
				charIndex = 0;
				checksum = 0;
				startNew = true;
				fieldID = 1;
				break;
			case ',':
				checksum ^= gpsField[charIndex];
				gpsField[charIndex] = '\0';
				charIndex = 0;
				if(sentenceID & 0x10)
					getSentenceData(); //sentence identified and we are collecting data
				else //still trying to identify sentence
				{
					if(strstr(gpsField,GPGGA)!=NULL)
					{
						if((sentenceID & 0xFF) == 0x07)
							sentenceID = 0x17;
						else
							resetAll(); //sentence found in wrong order, start over
					}
					else if(strstr(gpsField,GPGSA)!=NULL)
					{
						if((sentenceID & 0xFF) == 0x06)
							sentenceID = 0x16;
						else
							resetAll(); //sentence found in wrong order, start over
					}
					else if(strstr(gpsField,GPRMC)!=NULL)
					{
						if((sentenceID & 0xFF) == 0x04)
							sentenceID = 0x14;
						else
							resetAll(); //sentence found in wrong order, start over
					}
					else
						startNew = false; //trying this new code here to account for unused sentences
				}
				break;
			case '*':
				checksumR = checksum;
				checksum = 0;
				charIndex = 0;
				getSentenceData();
				sentenceID &= ~(0x10); // done collecting data for sentence
				break;
			case '\r':
				break;
			case '\n':
				if((gpsField[0]) >= 48 && (gpsField[0]) <= 57)
					checksum = (gpsField[0]-48) << 4;
				else
					checksum = (gpsField[0]-55) << 4;
				if((gpsField[1]) >= 48 && (gpsField[1]) <= 57)
					checksum |= (gpsField[1]-48);
				else
					checksum |= (gpsField[1]-55);	
				if(checksumR != checksum)
				{
					resetAll(); //incorrect checksum so all data is now invalid
					continue;
				}
				if(!sentenceID) //check to see if all sentences have been processed
				{
					resetAll(); //all sentences were processed successfully
					if(currentPosition.signalLock) //if satellite was locked then update all data
						{
							currentPosition.updated = 0xFF;
						//	*lastKnown = currentPosition;  //For some reason this code will not compile on Arduino 1.6.5 so we use below instead
							strcpy(lastKnown->latitude,currentPosition.latitude);
							strcpy(lastKnown->longitude,currentPosition.longitude);
							lastKnown->ns = currentPosition.ns;
							lastKnown->ew = currentPosition.ew;
							lastKnown->hour = currentPosition.hour;
							lastKnown->minute = currentPosition.minute;
							lastKnown->second = currentPosition.second;
							lastKnown->day = currentPosition.day;
							lastKnown->month = currentPosition.month;
							lastKnown->year = currentPosition.year;
							lastKnown->positionFixInd = currentPosition.positionFixInd;
							lastKnown->mode2 = currentPosition.mode2;
							lastKnown->pdop = currentPosition.pdop;
							lastKnown->hdop = currentPosition.hdop;
							lastKnown->vdop = currentPosition.vdop;
							lastKnown->speedKPH = currentPosition.speedKPH;
							lastKnown->speedMPH = currentPosition.speedMPH;
							lastKnown->course = currentPosition.course;
							lastKnown->satellitesUsed = currentPosition.satellitesUsed;
							lastKnown->altitudeM = currentPosition.altitudeM;
							lastKnown->altitudeFt = currentPosition.altitudeFt;
							lastKnown->signalLock = currentPosition.signalLock;
							lastKnown->updated = currentPosition.updated;
						}
						else
							lastKnown->signalLock = false; //do not update data with the exception of indicating there was no signal lock
						return 0; // all GPS sentence information collected and new data is now available
				}
				else
					startNew = false; //not all sentences were processed yet
			default:
				checksum ^= gpsField[charIndex];
				charIndex++;
				break;
		}
	}
}

void PA6H::getSentenceData()
{
	switch(sentenceID)
	{
		case 0x17: // GPGGA sentence
			switch(fieldID)
			{
				case 0x02:
					strcpy(currentPosition.latitude,gpsField);
					break;
				case 0x03:
					currentPosition.ns = gpsField[0];
					break;
				case 0x04:
					strcpy(currentPosition.longitude,gpsField);
					break;
				case 0x05:
					currentPosition.ew = gpsField[0];
					break;
				case 0x06:
					currentPosition.positionFixInd = atoi(gpsField);
					break;
				case 0x07:
					currentPosition.satellitesUsed = atoi(gpsField);
					break;
				case 0x09:
				{
					float altitude = atof(gpsField);
					currentPosition.altitudeM = (long) altitude;
					currentPosition.altitudeFt = (long) altitude * METERSTOFEET;
					sentenceID &= ~(0x01); // no longer collecting data from this sentence
				}
					break;
			}
			break;
		case 0x16:  //GPGSA sentence
			switch(fieldID)
			{
				case 0x02:
					currentPosition.mode2 = atoi(gpsField);
					break;
				case 0x0F:
					currentPosition.pdop = (uint16_t)(atof(gpsField)*100);
					break;
				case 0x10:
					currentPosition.hdop = (uint16_t)(atof(gpsField)*100);
					break;
				case 0x11:
					currentPosition.vdop = (uint16_t)(atof(gpsField)*100);
					sentenceID &= ~(0x02); // no longer collecting data from this sentence
					break;
			}
			break;
		case 0x14:  //GPRMC sentence
			switch(fieldID)
			{
				case 0x01:
					gpsField[6] = '\0';
					currentPosition.second = atoi(gpsField + 4);
					gpsField[4] = '\0';
					currentPosition.minute = atoi(gpsField + 2);
					gpsField[2] = '\0';
					currentPosition.hour = atoi(gpsField);
					break;
				case 0x02:
					if(gpsField[0] == 'A')
						currentPosition.signalLock = true;
					else
						currentPosition.signalLock = false;
					break;
				case 0x07:
				{
					float spd = atof(gpsField);
					currentPosition.speedKPH = (uint16_t) ((spd * KNOTSTOKPH) + 0.5); //rounded speed
					currentPosition.speedMPH = (uint16_t) ((spd * KNOTSTOMPH) + 0.5); //rounded speed
				}
					break;
				case 0x08:
					currentPosition.course = atoi(gpsField);
					break;
				case 0x09:
					currentPosition.year = atoi(gpsField + 4);
					gpsField[4] = '\0';
					currentPosition.month = atoi(gpsField + 2);
					gpsField[2] = '\0';
					currentPosition.day = atoi(gpsField);
					updateRegionalSettings(&currentPosition.hour, &currentPosition.month, &currentPosition.day, &currentPosition.year, tZ);
					sentenceID &= ~(0x04); // no longer collecting data from this sentence
					break;
			}
			break;
	}
	fieldID++;
}


void PA6H::updateRegionalSettings(int8_t *_hour, int8_t *_month, int8_t *_day, int8_t *_year, int8_t tzOffset)
{

	if(!tzOffset)
		return;
	int8_t dayOffset = 0;
	int8_t monthOffset = 0;
	*_hour += tzOffset;
	if(*_hour > 23)
	{
		*_hour -= 24;
		dayOffset++;
	}
	else if(*_hour < 0)
	{
		*_hour += 24;
		dayOffset--;
	}
	if(!dayOffset)
		return;
	*_day += dayOffset;
	switch(*_month)
	{
		case JANUARY:
			if(*_day == 32)
			{
				*_month++;
				*_day = 1;
			}
			else if(!*_day)
			{
				*_month = 12;
				*_year--;
				*_day = 31;
			}
			break;
		case APRIL:case JUNE:case SEPTEMBER:case NOVEMBER:
			if(*_day == 31)
				*_month++;
			else if(!*_day)
			{
				*_month--;
				*_day = 31;
			}
			break;
		case MARCH:case MAY:case JULY:case AUGUST:case OCTOBER:
			if(*_day == 32)
			{
				*_month++;
				*_day = 1;
			}
			else if(!*_day)
			{
				*_month--;
				if((*_month == APRIL)||(*_month == JUNE)||(*_month == SEPTEMBER))
					*_day = 30;
				else if(*_month = JULY)
					*_day = 31;
				else if(*_month == FEBRUARY)
				{
					if((*_year == 16)||(*_year == 20)||(*_year == 24)) //leap year
						*_day = 29;
					else
						*_day = 28;
				}
			}
			break;
		case FEBRUARY:
			if(*_day == 29)
			{
				*_month++;
				*_day = 1;
			}
			else if(!*_day)
			{
				*_month--;
				*_day = 31;
			}
			break;
		case DECEMBER:
			if(*_day == 32)
			{
				*_year++;
				*_month = 1;
				*_day = 1;
			}
			else if(!*_day) 
			{
				*_month--;
				*_day = 30;
			}
			break;
	}
}


void PA6H::sleepGPS()
{
	gpsSerial->println(PMTK161);
	delay(500);
}

void PA6H::wakeUpGPS()
{
	gpsSerial->println(PMTK000);
}
