/*** Draws 330uA of current in power down ***/
void alertOnMotion() //motion sensing mode
{
	if(motMonStatus == 1)
	{
		gps.sleepGPS();
		sim900.powerDownGSM();
		sleepForSeconds(0, true, false, true);
		gps.wakeUpGPS();
		sim900.initializeGSM();
		gsmPowerStatus = true;
		motMonStatus = 0x02;
	}
	if(motMonStatus == 2)
		interruptSMS(&motMonStatus, MOTIONMSG);
}


/***************************************
Adjusting sensitivity for accelerometer
0x27(126) slope   0x28(127) threshhold

0x27 = 0: 0x28 = 4		too sensitive
0x27 = 5: 0x28 = 4		looks good, needs further testing

***************************************/