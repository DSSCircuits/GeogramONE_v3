
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


/**********************************/

#define PG_INT             		14
#define BMA_ADD    	   (uint8_t)0x18
#define FUELGAUGE          		0x36 //Fuel gauge I2C address
#define FUELGAUGEPIN       		0x07 //Fuel gauge interrupt pin


