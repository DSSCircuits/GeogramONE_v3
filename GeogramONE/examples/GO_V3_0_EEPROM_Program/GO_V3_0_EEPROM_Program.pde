
#include <EEPROM.h>
#include "eepromAnything.h"

/*******EEPROM ADDRESSES**********/
#define PINCODE         		0
#define SMSADDRESS				5
#define RETURNADDCONFIG			21
#define TIMEZONE				22   //use -4 for EST
#define ENGMETRIC				23   // 0 - English (mph, ft, etc...), 1 = Metric (kph, m, etc...)
#define BATTERYLOWLEVEL    		24
#define IOSTATE0				25
#define IOSTATE1				26
#define IOSTATE2				27
#define IOSTATE3				28
#define IOSTATE4				29
#define IOSTATE5				30
#define IOSINGLEPULSETIME		31
#define IODOUBLEPULSETIME1		32
#define IODOUBLEPULSETIME2		33
#define IODOUBLEPULSETIME3		34
#define SLEEPTIMECONFIG			35
#define SLEEPTIMEON				36
#define SLEEPTIMEOFF			40
#define SPEEDLIMIT				44
#define SPEEDHYST				46
#define RADIUS1					47
#define LATITUDE1				51
#define LONGITUDE1				55
#define RADIUS2					59
#define LATITUDE2				63
#define LONGITUDE2				67
#define RADIUS3					71
#define LATITUDE3				75
#define LONGITUDE3				79
#define BREACHSPEED				83
#define BREACHREPS				84
#define BMA0X0F					85
#define BMA0X10					86
#define BMA0X11					87
#define BMA0X16					88
#define BMA0X17					89
#define BMA0X19					90
#define BMA0X1A					91
#define BMA0X1B					92
#define BMA0X20					93
#define BMA0X21					94
#define BMA0X25					95
#define BMA0X26					96
#define BMA0X27					97
#define BMA0X28					98
#define UDPSENDINTERVALBAT		99
#define UDPSENDINTERVALPLUG		103
#define UDPPOWERPROFILE			107
#define UDPSPEEDBAT				108
#define UDPSPEEDPLUG			109
#define SMSSENDINTERVALBAT		110
#define SMSSENDINTERVALPLUG		114
#define SMSPOWERPROFILE			118
#define SMSSPEEDBAT				119
#define SMSSPEEDPLUG			120
#define MOTIONMSG				121
#define BATTERYMSG				137
#define FENCE1MSG				153
#define FENCE2MSG				169
#define FENCE3MSG				185
#define SPEEDMSG				201
#define MAXSPEEDMSG				217
#define GEOGRAMONEID			233
#define D4MSG					249
#define D10MSG					265
#define HTTP1					281
#define IMEI					317
#define GPRS_APN				333
#define GPRS_HOST				369
#define GPRS_PORT				405
#define UDP_HEADER				407

#define SPACE					"        "
#define SPACE2					"        "


void setup()
{
	Serial.begin(9600);
	delay(500);
    Serial.flush();
    while(!Serial.available()){}

}

void loop()
{
	char pincode[5] = "0000"; //pincode must be 4 digits   /**** DEFAULT VALUE STORED IN EEPROM ****/
	char smsaddress[16] = ""; //smsaddress must be 38 characters or less   /**** DEFAULT VALUE STORED IN EEPROM ****/
	char batteryMsg[16] = "Low Battery"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char motionMsg[16] = "Motion Detected"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char fence1Msg[16] = "Fence 1 Breach"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char fence2Msg[16] = "Fence 2 Breach"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char fence3Msg[16] = "Fence 3 Breach"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char speedMsg[16] = "Speed Exceeded"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char geoIDMsg[16] = "GO FW_3.0b"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char maxSpeedMsg[16] = "Max Speed = "; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char http1[36] = "http://maps.google.com/maps?q="; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char d4msg[16] = "Pin D4 Alert"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char d10msg[16] = "Pin D10 Alert"; /**** DEFAULT VALUE STORED IN EEPROM ****/
	char imei[16] = "*"; //15 digit number on GSM chip /**** DEFAULT VALUE STORED IN EEPROM ****/
	char udpApn[36] = "wholesale"; //SIM card specific APN.  wholesale is used on Platinumtel /**** DEFAULT VALUE STORED IN EEPROM ****/
	char udpHost[36] = "193.193.165.166"; //Server address for GPS-Trace Orange /**** DEFAULT VALUE STORED IN EEPROM ****/
	char udpHeader[16] = "#SD#"; /**** DEFAULT VALUE STORED IN EEPROM ****/

	char textIn = NULL;
	bool w = false;

    Serial.println("PRESS P - PROGRAM EEPROM, R - READ EEPROM, C - CLEAR EEPROM");
    while(1)
	{
		if(Serial.available())
		{
			textIn = Serial.read();
			if((textIn == 'p') || (textIn == 'P'))
			{
				w = true;
				Serial.println("Reg#     Written         Read Back");
				break;
			}
			if((textIn == 'R') || (textIn == 'r'))
			{
				w = false;
				Serial.println("Reg#    Default       Current");
				break;
			}
			if((textIn == 'c') || (textIn == 'C'))
			{
				for(uint16_t eepromAddress = 0;eepromAddress <= 1023;eepromAddress++)
				{
					EEPROM.write(eepromAddress,0xFF);
				}
				Serial.println("EEPROM HAS BEEN CLEARED OF ALL CONTENTS");
				return;
			}
		}
	}
	Serial.flush();
	Serial.println("-------------------------------------");
	
	uint8_t abyte;
	int8_t sbyte;
	uint16_t ninteger;
	unsigned long ulong;
	int32_t slong;
	
	Serial.print(PINCODE);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(PINCODE,pincode);
	Serial.print(pincode);Serial.print(SPACE2);
	EEPROM_readAnything(PINCODE,pincode);Serial.println(pincode);
	
	Serial.print(SMSADDRESS);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(SMSADDRESS,smsaddress);
	Serial.print(smsaddress);Serial.print(SPACE2);
	EEPROM_readAnything(SMSADDRESS,smsaddress);Serial.println(smsaddress);
	
	Serial.print(RETURNADDCONFIG);Serial.print(SPACE);	
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(RETURNADDCONFIG,(uint8_t)abyte); //changed to a 1 from 0
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(RETURNADDCONFIG,abyte);Serial.println(abyte,DEC);

	Serial.print(TIMEZONE);Serial.print(SPACE);
	sbyte = -4; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(TIMEZONE,(int8_t)sbyte);   //use -4 for EST
	Serial.print(sbyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(TIMEZONE,sbyte);Serial.println(sbyte,DEC);
	
	Serial.print(ENGMETRIC);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(ENGMETRIC,(uint8_t)abyte);  // 0 - English (mph, ft, etc...), 1 = Metric (kph, m, etc...)
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(ENGMETRIC,abyte);Serial.println(abyte,DEC);

	Serial.print(BATTERYLOWLEVEL);Serial.print(SPACE);
	abyte = 32; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BATTERYLOWLEVEL,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BATTERYLOWLEVEL,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE0);Serial.print(SPACE);
	abyte = 2; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE0,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE0,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE1);Serial.print(SPACE);
	abyte = 4; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE1,(uint8_t)abyte); //int falling
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE1,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE2);Serial.print(SPACE);
	abyte = 2; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE2,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE2,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE3);Serial.print(SPACE);
	abyte = 2; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE3,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE3,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE4);Serial.print(SPACE);
	abyte = 2; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE4,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE4,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSTATE5);Serial.print(SPACE);
	abyte = 3; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSTATE5,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSTATE5,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IOSINGLEPULSETIME);Serial.print(SPACE);
	abyte = 255; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IOSINGLEPULSETIME,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IOSINGLEPULSETIME,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IODOUBLEPULSETIME1);Serial.print(SPACE);
	abyte = 255; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IODOUBLEPULSETIME1,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IODOUBLEPULSETIME1,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IODOUBLEPULSETIME2);Serial.print(SPACE);
	abyte = 255; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IODOUBLEPULSETIME2,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IODOUBLEPULSETIME2,abyte);Serial.println(abyte,DEC);
	
	Serial.print(IODOUBLEPULSETIME3);Serial.print(SPACE);
	abyte = 255; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(IODOUBLEPULSETIME3,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(IODOUBLEPULSETIME3,abyte);Serial.println(abyte,DEC);

	Serial.print(SLEEPTIMECONFIG);Serial.print(SPACE);
	abyte = 3; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SLEEPTIMECONFIG,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SLEEPTIMECONFIG,abyte);Serial.println(abyte,DEC);

	Serial.print(SLEEPTIMEON);Serial.print(SPACE);
	ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SLEEPTIMEON,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SLEEPTIMEON,ulong);Serial.println(ulong,DEC);
	
	Serial.print(SLEEPTIMEOFF);Serial.print(SPACE);
	ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SLEEPTIMEOFF,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SLEEPTIMEOFF,ulong);Serial.println(ulong,DEC);
	
	Serial.print(SPEEDLIMIT);Serial.print(SPACE);
	ninteger = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SPEEDLIMIT,(uint16_t)ninteger);
	Serial.print(ninteger,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SPEEDLIMIT,ninteger);Serial.println(ninteger,DEC);
	
	Serial.print(SPEEDHYST);Serial.print(SPACE);
	abyte = 3; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SPEEDHYST,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SPEEDHYST,abyte);Serial.println(abyte,DEC);
	
	Serial.print(RADIUS1);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(RADIUS1,(unsigned long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(RADIUS1,slong);Serial.println(slong,DEC);

	Serial.print(LATITUDE1);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LATITUDE1,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LATITUDE1,slong);Serial.println(slong,DEC);

	Serial.print(LONGITUDE1);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LONGITUDE1,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LONGITUDE1,slong);Serial.println(slong,DEC);

	Serial.print(RADIUS2);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(RADIUS2,(unsigned long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(RADIUS2,slong);Serial.println(slong,DEC);

	Serial.print(LATITUDE2);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LATITUDE2,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LATITUDE2,slong);Serial.println(slong,DEC);

	Serial.print(LONGITUDE2);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LONGITUDE2,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LONGITUDE2,slong);Serial.println(slong,DEC);
	
	Serial.print(RADIUS3);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(RADIUS3,(unsigned long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(RADIUS3,slong);Serial.println(slong,DEC);
	
	Serial.print(LATITUDE3);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LATITUDE3,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LATITUDE3,slong);Serial.println(slong,DEC);
	
	Serial.print(LONGITUDE3);Serial.print(SPACE);
	slong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(LONGITUDE3,(long)slong);
	Serial.print(slong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(LONGITUDE3,slong);Serial.println(slong,DEC);
	
	Serial.print(BREACHSPEED);Serial.print(SPACE);
	abyte = 3; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BREACHSPEED,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BREACHSPEED,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BREACHREPS);Serial.print(SPACE);
	abyte = 10; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BREACHREPS,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BREACHREPS,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X0F);Serial.print(SPACE);
	abyte = 5; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X0F,(uint8_t)abyte); //was 3
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X0F,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X10);Serial.print(SPACE);
	abyte = 8; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X10,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X10,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X11);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X11,(uint8_t)abyte); //default 0x00 per datasheet
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X11,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X16);Serial.print(SPACE);
	abyte = 7; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X16,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X16,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X17);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X17,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X17,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X19);Serial.print(SPACE);
	abyte = 4; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X19,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X19,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X1A);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X1A,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X1A,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X1B);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X1B,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X1B,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X20);Serial.print(SPACE);
	abyte = 6; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X20,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X20,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X21);Serial.print(SPACE);
	abyte = 0x8E; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X21,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X21,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X25);Serial.print(SPACE);
	abyte = 0x0F; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X25,(uint8_t)abyte); //default 0x0F per datasheet
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X25,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X26);Serial.print(SPACE);
	abyte = 0xC0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X26,(uint8_t)abyte); //default 0xC0 per datasheet
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X26,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X27);Serial.print(SPACE);
	abyte = 5; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X27,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X27,abyte);Serial.println(abyte,DEC);
	
	Serial.print(BMA0X28);Serial.print(SPACE);
	abyte = 4; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(BMA0X28,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(BMA0X28,abyte);Serial.println(abyte,DEC);
	
	Serial.print(UDPSENDINTERVALBAT);Serial.print(SPACE);
    ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(UDPSENDINTERVALBAT,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(UDPSENDINTERVALBAT,ulong);Serial.println(ulong,DEC);
	
	Serial.print(UDPSENDINTERVALPLUG);Serial.print(SPACE);
	ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(UDPSENDINTERVALPLUG,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(UDPSENDINTERVALPLUG,ulong);Serial.println(ulong,DEC);
	
	Serial.print(UDPPOWERPROFILE);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(UDPPOWERPROFILE,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(UDPPOWERPROFILE,abyte);Serial.println(abyte,DEC);
	
	Serial.print(UDPSPEEDBAT);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(UDPSPEEDBAT,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(UDPSPEEDBAT,abyte);Serial.println(abyte,DEC);
	
	Serial.print(UDPSPEEDPLUG);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(UDPSPEEDPLUG,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(UDPSPEEDPLUG,abyte);Serial.println(abyte,DEC);
	
	Serial.print(SMSSENDINTERVALBAT);Serial.print(SPACE);
	ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SMSSENDINTERVALBAT,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SMSSENDINTERVALBAT,ulong);Serial.println(ulong,DEC);
	
	Serial.print(SMSSENDINTERVALPLUG);Serial.print(SPACE);
	ulong = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SMSSENDINTERVALPLUG,(unsigned long)ulong);
	Serial.print(ulong,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SMSSENDINTERVALPLUG,ulong);Serial.println(ulong,DEC);
	
	Serial.print(SMSPOWERPROFILE);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SMSPOWERPROFILE,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SMSPOWERPROFILE,abyte);Serial.println(abyte,DEC);
	
	Serial.print(SMSSPEEDBAT);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SMSSPEEDBAT,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SMSSPEEDBAT,abyte);Serial.println(abyte,DEC);
	
	Serial.print(SMSSPEEDPLUG);Serial.print(SPACE);
	abyte = 0; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(SMSSPEEDPLUG,(uint8_t)abyte);
	Serial.print(abyte,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(SMSSPEEDPLUG,abyte);Serial.println(abyte,DEC);
	
	Serial.print(MOTIONMSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(MOTIONMSG,motionMsg);
	Serial.print(motionMsg);Serial.print(SPACE2);
	EEPROM_readAnything(MOTIONMSG,motionMsg);Serial.println(motionMsg);
	
	Serial.print(BATTERYMSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(BATTERYMSG,batteryMsg);
	Serial.print(batteryMsg);Serial.print(SPACE2);
	EEPROM_readAnything(BATTERYMSG,batteryMsg);Serial.println(batteryMsg);
	
	Serial.print(FENCE1MSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(FENCE1MSG,fence1Msg);
	Serial.print(fence1Msg);Serial.print(SPACE2);
	EEPROM_readAnything(FENCE1MSG,fence1Msg);Serial.println(fence1Msg);
	
	Serial.print(FENCE2MSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(FENCE2MSG,fence2Msg);
	Serial.print(fence2Msg);Serial.print(SPACE2);
	EEPROM_readAnything(FENCE2MSG,fence2Msg);Serial.println(fence2Msg);
	
	Serial.print(FENCE3MSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(FENCE3MSG,fence3Msg);
	Serial.print(fence3Msg);Serial.print(SPACE2);
	EEPROM_readAnything(FENCE3MSG,fence3Msg);Serial.println(fence3Msg);
	
	Serial.print(SPEEDMSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(SPEEDMSG,speedMsg);
	Serial.print(speedMsg);Serial.print(SPACE2);
	EEPROM_readAnything(SPEEDMSG,speedMsg);Serial.println(speedMsg);
	
	Serial.print(MAXSPEEDMSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(MAXSPEEDMSG,maxSpeedMsg);
	Serial.print(maxSpeedMsg);Serial.print(SPACE2);
	EEPROM_readAnything(MAXSPEEDMSG,maxSpeedMsg);Serial.println(maxSpeedMsg);
	
	Serial.print(GEOGRAMONEID);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(GEOGRAMONEID,geoIDMsg);
	Serial.print(geoIDMsg);Serial.print(SPACE2);
	EEPROM_readAnything(GEOGRAMONEID,geoIDMsg);Serial.println(geoIDMsg);

	Serial.print(D4MSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(D4MSG,d4msg);
	Serial.print(d4msg);Serial.print(SPACE2);
	EEPROM_readAnything(D4MSG,d4msg);Serial.println(d4msg);
	
	Serial.print(D10MSG);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(D10MSG,d10msg);
	Serial.print(d10msg);Serial.print(SPACE2);
	EEPROM_readAnything(D10MSG,d10msg);Serial.println(d10msg);
	
	Serial.print(HTTP1);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(HTTP1,http1);
	Serial.print(http1);Serial.print(SPACE2);
	EEPROM_readAnything(HTTP1,http1);Serial.println(http1);

	Serial.print(IMEI);Serial.print(SPACE);
	if(w)EEPROM_writeAnything(IMEI,imei);
	Serial.print(imei);Serial.print(SPACE2);
	EEPROM_readAnything(IMEI,imei);Serial.println(imei);

	Serial.print(GPRS_APN);Serial.print(SPACE);
 	if(w)EEPROM_writeAnything(GPRS_APN,udpApn);
	Serial.print(udpApn);Serial.print(SPACE2);
	EEPROM_readAnything(GPRS_APN,udpApn);Serial.println(udpApn);

	Serial.print(GPRS_HOST);Serial.print(SPACE);
 	if(w)EEPROM_writeAnything(GPRS_HOST,udpHost);
	Serial.print(udpHost);Serial.print(SPACE2);
	EEPROM_readAnything(GPRS_HOST,udpHost);Serial.println(udpHost);

	Serial.print(GPRS_PORT);Serial.print(SPACE);
	ninteger = 20332; /**** DEFAULT VALUE STORED IN EEPROM ****/
	if(w)EEPROM_writeAnything(GPRS_PORT,(uint16_t)ninteger); //GPRS port number
	Serial.print(ninteger,DEC);Serial.print(SPACE2);
	EEPROM_readAnything(GPRS_PORT,ninteger);Serial.println(ninteger,DEC);

	Serial.print(UDP_HEADER);Serial.print(SPACE);
 	if(w)EEPROM_writeAnything(UDP_HEADER,udpHeader);
	Serial.print(udpHeader);Serial.print(SPACE2);
	EEPROM_readAnything(UDP_HEADER,udpHeader);Serial.println(udpHeader);

	Serial.print("Finished ");
	if(w)Serial.print("Writing ");
	else
		Serial.print("Reading ");
	Serial.println("EEPROM");
	Serial.println();
	Serial.println();

}
