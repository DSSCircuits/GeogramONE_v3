void sleepTimer()
{
	uint32_t sleepTimeOn;
	uint32_t sleepTimeOff;
	uint8_t sleepTimeConfig;
	static unsigned long onOffTimer;
	static bool reloadTimer = true;
	if(call) //do not go to sleep until all pending SMS's are serviced
		return;
	EEPROM_readAnything(SLEEPTIMEON,sleepTimeOn);
	EEPROM_readAnything(SLEEPTIMEOFF,sleepTimeOff);
	if((!sleepTimeOn) || (!sleepTimeOff))
		return;
	sleepTimeOn *= 1000;
	sleepTimeConfig = EEPROM.read(SLEEPTIMECONFIG);
	bool wakeOnMotion = sleepTimeConfig & 0x08;
	bool wakeOnCharger = sleepTimeConfig & 0x04;
	bool turnGpsOff = sleepTimeConfig & 0x02;
	bool turnGsmOff = sleepTimeConfig & 0x01;
	if( (wakeOnMotion && (move & 0x01)) || (wakeOnCharger && charge) )
	{
		move &= ~(0x01);
		reloadTimer = true;
		return;
	}
	if(reloadTimer)
	{
		onOffTimer = millis();
		reloadTimer = false;
	}
	if((millis() - onOffTimer) < (sleepTimeOn))
		return;
	if(turnGpsOff)
		gps.sleepGPS();
	if(turnGsmOff)
		sim900.powerDownGSM();
	sleepForSeconds(sleepTimeOff, wakeOnMotion, wakeOnCharger, false);
	if(turnGpsOff)
		gps.wakeUpGPS();
	if(turnGsmOff)
		sim900.initializeGSM();
	gsmPowerStatus = true;	
	reloadTimer = true;	
}

void sleepForSeconds(uint32_t delaySeconds, bool wakeOnMotion, bool wakeOnCharger, bool powerDown)
{
	uint8_t pcicrReg = PCICR; //backup the current Pin Change Interrupt register
	uint8_t oldSREG = SREG;
	pinMode(9,INPUT);  //shut off AltSoftSerial Tx pin . Takes it down another 4ma
	digitalWrite(9,LOW); //set to high impedance
	digitalWrite(8,LOW); // set AltSoftSerial Rx pin to high impedance
	delay(500);
	BMA250sleepMode(0x5E); //was 0x5A
	if(!wakeOnMotion)
		BMA250disableInterrupts();
	else
		BMA250enableInterrupts();
	MAX17043sleep(false);
	move &= ~(0x80);
	ADCSRA = 0; // ~200ua less
	PRR = 0xAF;  // turn off various modules
	if(powerDown)
	{
		set_sleep_mode (SLEEP_MODE_PWR_DOWN);
		while(1)
		{
			d11PowerSwitch = 0;
			sleep_enable();	
			MCUCR = _BV (BODS) | _BV (BODSE);
			MCUCR = _BV (BODS);
			sleep_cpu ();
		/*********ATMEGA is sleeping at this point***************/	
			sleep_disable();
			if((wakeOnMotion && (move & 0x80)))
				break;
			if(powerDown && d11PowerSwitch)
			{
				PRR = 0x04;  // need to turn timer0 back on to use delay()
				delay(2000);
				if(!digitalRead(11))
					break;
				PRR = 0xAF;  // turn off various modules
			}
		}
	}
	else
	{
		extern volatile unsigned long timer0_overflow_count;
		extern volatile unsigned long timer0_millis;
		unsigned long tm = 0;
		uint32_t nSeconds = (delaySeconds / 0.032768);
		sleepTimer2Overflow = 0;
		set_sleep_mode (SLEEP_MODE_PWR_SAVE); 
		cli();
		TCCR0B = 0x00;
		tm = timer0_millis;
		TCCR0B = 0x03; 
		sei();
		TCCR2B = 0x00; // stop timer2
		TCNT2=0x0000; // reset timer2 to count of zero
		while(sleepTimer2Overflow < nSeconds)
		{
			TCCR2B = 0x07; // start timer2 counting
			sleep_enable();	
			MCUCR = _BV (BODS) | _BV (BODSE);
			MCUCR = _BV (BODS);
			sleep_cpu ();
		/*********ATMEGA is sleeping at this point***************/	
			sleep_disable();
			TCCR2B = 0x00; // stop timer2
			if(  (wakeOnMotion && (move & 0x80))   ||   (wakeOnCharger && (charge & 0x02))  )
				break;
		}
		TCCR2B = 0x00; // stop timer2
		cli();
		TCCR0B = 0x00;
		timer0_millis = tm + (sleepTimer2Overflow * 32.870) + ((TCNT2/7812.5) * 1000); //original was 32.768
		TCCR0B = 0x03;
		sei();
	}
	PRR = 0x04;  // turn on everything except SPI
	PCICR = pcicrReg; //restore Pin Change Interrupt register
	MAX17043sleep(true);
	BMA250sleepMode(0x00);
	BMA250enableInterrupts();
	pinMode(9,OUTPUT); //restore AltSoftSerial settings 
	digitalWrite(9,HIGH);
	digitalWrite(8,HIGH);
}

			

