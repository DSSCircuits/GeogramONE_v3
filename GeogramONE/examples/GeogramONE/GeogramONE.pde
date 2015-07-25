/*****************************************************************************
The Geogram ONE is an open source tracking device/development board based off 
the Arduino platform.  The hardware design and software files are released 
under CC-SA v3 license.
*****************************************************************************/

#include <AltSoftSerial.h>
#include <PinChangeInt.h>
#include "GeogramONE.h"
#include <EEPROM.h>
#include <I2C.h>
#include "eepromAnything.h"
#include <avr/sleep.h>
#include "SIMCOM.h"
#include "PA6H.h"

AltSoftSerial GSM;
SIMCOM sim900(&GSM);
geoSmsData smsData;
PA6H gps(&Serial); 
goCoord lastValid;


volatile uint32_t sleepTimer2Overflow = 0;

volatile uint8_t call = 0; //trying a 1 to see if it works
volatile uint8_t move;
volatile uint8_t battery = 0;
volatile uint8_t charge = 0x02; // force a read of the charger cable
volatile uint8_t d4Switch = false;
volatile uint8_t d10Switch = 0x00;

volatile uint8_t d11PowerSwitch;

uint8_t smsPosStatus = 0;
uint8_t motMonStatus = 0;
uint8_t spdMonStatus = 0;
uint8_t udp = 0x00; 
uint8_t digitalReadPin = 0;
uint8_t analogReadPin = 0;


uint32_t smsInterval = 0;
uint32_t udpInterval = 0;

uint16_t speedLimit = 0;

uint8_t smsPowerProfile = 0;
uint8_t udpPowerProfile = 0;
uint8_t smsPowerSpeed = 0;
uint8_t udpPowerSpeed = 0;

bool gsmPowerStatus = true;

uint8_t f1 = EEPROM.read(BREACHREPS);
uint8_t f2 = f1;
uint8_t f3 = f1;
uint8_t f1Alarm = 0;
uint8_t f2Alarm = 0;
uint8_t f3Alarm = 0;

#define USE_UDP				1
#define USE_GEOFENCE		1
#define USE_SPEED_ALERT		1


void setup()
{
/******Initialize communications*****************/
	Serial.begin(115200);
	GSM.begin(9600);
	I2c.begin();
	I2c.timeOut(500);
/************************************************/	

/******Configure IO Pins*************************/	
	pinMode(14 ,INPUT);     //Power Good Interrupt Pin
	digitalWrite(14 ,LOW);
	PCintPort::attachInterrupt(14, &charger, CHANGE);
/**************************************/	
	pinMode(7,INPUT);       //Fuel Gauge Interrupt Pin
	digitalWrite(7,HIGH);
	PCintPort::attachInterrupt(FUELGAUGEPIN, &lowBattery, FALLING);
/**************************************/
	pinMode(3,INPUT);       //Accelerometer Interrupt 1 Pin
	digitalWrite(3,HIGH);
	attachInterrupt(1, movement, FALLING);
/**************************************/
	pinMode(11,INPUT);      //On Off Power Switch Pin
	digitalWrite(11,HIGH);
	PCintPort::attachInterrupt(11, &d11Interrupt, FALLING);
/**************************************/	
	pinMode(2,INPUT);		//Ring Indicator Interrupt Pin
	attachInterrupt(0, ringIndicator, FALLING);
/**************************************/
	pinMode(5,INPUT);		//GSM Status Pin
/**************************************/
	pinMode(6,OUTPUT);		//GSM Power Switch
	digitalWrite(6,LOW);
/************************************************/
	configureIoPin(4,EEPROM.read(IOSTATE0));
	configureIoPin(10,EEPROM.read(IOSTATE1));
	configureIoPin(1,EEPROM.read(IOSTATE2));
	configureIoPin(2,EEPROM.read(IOSTATE3));
	configureIoPin(3,EEPROM.read(IOSTATE4));
	configureIoPin(6,EEPROM.read(IOSTATE5));
/************************************************/

/******Initialize Fuel Gauge*********************/	
	MAX17043init();
	battery = MAX17043getAlertFlag();
/************************************************/
	
/******Initialize Accelerometer******************/	
	BMA250configureMotion();
	BMA250configureInterrupts();
	BMA250enableInterrupts();
/************************************************/

/******Initialize GPS****************************/	
	gps.init();
/************************************************/	
	
/******Initialize GSM****************************/	
	sim900.initializeGSM();
/************************************************/	

/******Initialize TIMER2*************************/
	TCCR2A = 0x00; //normal operation of timer2
	TCNT2=0x0000; //where to start counting from
	TIMSK2=0x01; //enable timer2 overflow interrupt
	TCCR2B = 0x00; //when set to 7, set clock prescalar to 1024 and start counting. Stops counter when set to zero
	PRR = 0x04;  // turn on everything except SPI
/************************************************/

}

void loop()
{
	gps.getCoordinates(&lastValid, EEPROM.read(TIMEZONE));
	if(call)
	{
		sim900.gsmSleepMode(0);
		char pwd[5];
		EEPROM_readAnything(PINCODE,pwd);
		if(sim900.signalQuality())
		{
			if(!sim900.getGeo(&smsData, pwd))
			{
				if(!smsData.smsPending)
					call = 0; // no more messages
				if(smsData.smsDataValid)
				{
					switch(smsData.smsCmdNum)
					{
						case 0x00:
							smsPosStatus = 0x01;
							break;
						case 0x01:
							motMonStatus = 0x01;
							break;
						case 0x02:
							setEeprom();
							break;
						case 0x03:
							getEeprom();
							break;
						case 255:
							sim900.rebootGSM();
							gsmPowerStatus = true;
							break;
					}
				}
			}
		}
		sim900.gsmSleepMode(2);	
	}
	if(digitalReadPin)
		sendIO(true,digitalReadPin);
	if(analogReadPin)
		sendIO(false,analogReadPin);
	if(smsPosStatus)
		smsPosition();
	alertOnMotion();
#if USE_SPEED_ALERT
	alertOnSpeed();
#endif
#if USE_UDP
	if(udp && (lastValid.signalLock && (lastValid.updated & 0x01)))
	{
		sim900.gsmSleepMode(0);
		if(!udpPosition())
		{
			udp = 0;
			lastValid.updated &= ~(0x01);
		}
		sim900.gsmSleepMode(2);
	}
#endif
	if(battery)
	{
		interruptSMS(&battery, BATTERYMSG);
		if(!battery)
			MAX17043clearAlertFlag();
	}
	if(charge & 0x02)
		chargerStatus();
	smsPowerProfile = EEPROM.read(SMSPOWERPROFILE);
	udpPowerProfile = EEPROM.read(UDPPOWERPROFILE);
	if(!charge)
	{	
		smsPowerProfile >>= 4;
		udpPowerProfile >>= 4;
		EEPROM_readAnything(SMSSENDINTERVALBAT,smsInterval);
		EEPROM_readAnything(UDPSENDINTERVALBAT,udpInterval);
		smsPowerSpeed = EEPROM.read(SMSSPEEDBAT);
		udpPowerSpeed = EEPROM.read(UDPSPEEDBAT);
	}
	else
	{
		EEPROM_readAnything(SMSSENDINTERVALPLUG,smsInterval);
		EEPROM_readAnything(UDPSENDINTERVALPLUG,udpInterval);
		smsPowerSpeed = EEPROM.read(SMSSPEEDPLUG);
		udpPowerSpeed = EEPROM.read(UDPSPEEDPLUG);
	}
	if(smsInterval)
		smsTimerMenu();
	if(udpInterval)
		udpTimerMenu();
#if USE_GEOFENCE
	geoFence(); 
#endif

	if(d4Switch)
		interruptSMS(&d4Switch, D4MSG);
	if(d10Switch)
		interruptSMS(&d10Switch, D10MSG);
	sleepTimer();
	if(d11PowerSwitch)
	{
		delay(2000);
		if(!digitalRead(11))
		{
			gps.sleepGPS();
			sim900.powerDownGSM();
			sleepForSeconds(0, false, false, true); //draws about 330uA
			gps.wakeUpGPS();
			sim900.initializeGSM();
		}
		d11PowerSwitch = 0;
		gsmPowerStatus = true;
	}
	if(gsmPowerStatus)
		sim900.initializeGSM();
} 

void printEEPROM(uint16_t eAddress)
{
	char eepChar;
	for (uint8_t ep = 0; ep < 50; ep++)
	{
		eepChar = EEPROM.read(ep + eAddress);
		if(eepChar == '\0')
			break;
		else
			GSM.print(eepChar);
	}
}

bool goesWhere(char *smsAddress, uint8_t replyOrStored)
{
	if(replyOrStored == 3) 
		EEPROM_readAnything(RETURNADDCONFIG,replyOrStored);
	if((replyOrStored == 1))
		for(uint8_t l = 0; l < 39; l++)
		{
				smsAddress[l] = EEPROM.read(l + SMSADDRESS);
				if(smsAddress[l] == NULL)
					break;
		}
	if(smsAddress[0] == ' ')
		return false;
	return true;
}

void interruptSMS(volatile uint8_t *status, uint16_t eAddress)
{
	if(!startSMSSend(1))
	{
		printEEPROM(eAddress);
		if(!sim900.sendSMS())
			*status = 0x00;
	}
	sim900.gsmSleepMode(2);
}

bool startSMSSend(uint8_t ros) //28754
{
	sim900.gsmSleepMode(0);
	if(!goesWhere(smsData.smsNumber,ros))
		return true;
	return(sim900.prepareSMS(smsData.smsNumber));
}
	
