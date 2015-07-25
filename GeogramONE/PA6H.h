
#ifndef PA6H_h
#define PA6H_h

#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

#define GPSTIMEOUT			1100
#define METERSTOFEET		3.2808
#define KPHTOMPH			0.621371
#define KNOTSTOMPH			1.15078
#define KNOTSTOKPH			1.852

#define GPGGA				"GA"
#define GPGSA				"SA"
#define GPGSV				"SV"
#define GPRMC				"MC"
#define GPVTG				"TG"

#define PMTK161				"$PMTK161,0*28"
#define PMTK000				"$PMTK000*32"

#define JANUARY				1
#define FEBRUARY			2
#define MARCH				3
#define APRIL				4
#define MAY					5
#define JUNE				6
#define JULY				7
#define AUGUST				8
#define SEPTEMBER			9
#define OCTOBER				10
#define NOVEMBER			11
#define DECEMBER			12
			
struct goCoord
{
	char latitude[10];
	char longitude[11];
	char ns;
	char ew;
	int8_t hour;
	int8_t minute;
	int8_t second;
	int8_t day;
	int8_t month;
	int8_t year;
	uint8_t positionFixInd;
	uint8_t mode2;
	uint16_t pdop;
	uint16_t hdop;
	uint16_t vdop;
	uint16_t speedKPH;
	uint16_t speedMPH;
	uint16_t course;
	int satellitesUsed;
	long altitudeM;
	long altitudeFt;
	bool signalLock;
	uint8_t updated;
};

class PA6H
{
	public:
		void init();
		uint8_t getCoordinates(goCoord *, int8_t);
		void sleepGPS();
		void wakeUpGPS();
		PA6H(HardwareSerial *ser);
	private:
		int8_t tZ;
		goCoord currentPosition;
		char gpsField[15];
		bool startNew; 
		uint8_t charIndex;
		uint8_t checksum;
		uint8_t checksumR;
		uint8_t sentenceID;
		uint8_t fieldID;
		void resetAll();
		void getSentenceData();
		void updateRegionalSettings(int8_t *, int8_t *, int8_t *, int8_t *, int8_t);
		HardwareSerial *gpsSerial;
};

#endif