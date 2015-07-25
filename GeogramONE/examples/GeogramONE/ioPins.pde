/***************************************************************
/***Pin Numbers***
0 - Digital Pin D4
1 - Digital Pin D10
2 - Digital Pin D15 / Analog Pin A1 
3 - Digital Pin D16 / Analog Pin A2
4 - Digital Pin D17 / Analog Pin A3
5 - Analog Pin A6
*******************/
/***Pinstate********
0 - Output Low
1 - Output High
2 - Digital In
3 - Analog In
4 - Interrupt Falling (D4 and D10 only)
5 - Read Pin  
6 - Single Pulse H -> L -> H (Output High config only) 
7 - Double Pulse H -> L -> H -> L -> H (Output High config only)
****************************************************************/
void configureIoPin(uint8_t pinNumber, uint8_t pinState)
{
	if(pinState == 3)
	{
		if((pinNumber == 4) || (pinNumber == 10))
			return;
		analogReference(DEFAULT);
		analogRead(pinNumber);
	}
	else
	{
		if(pinNumber == 6)
			return;
		if((pinNumber > 0) && (pinNumber < 4))
			pinNumber += 14;
		if((pinState == 2) || (pinState == 4))
		{
			pinMode(pinNumber,INPUT);
			digitalWrite(pinNumber,HIGH);
		}
		else if(pinState < 2)
		{
			pinMode(pinNumber,OUTPUT);
			digitalWrite(pinNumber,pinState & 0x01);
		}
		if(pinState == 4)
		{
			if(pinNumber == 4)
			{
				PCintPort::attachInterrupt(4, &d4Interrupt, FALLING);
				d4Switch = 0;
			}
			if(pinNumber == 10)
			{
				PCintPort::attachInterrupt(10, &d10Interrupt, FALLING);
				d10Switch = 0;
			}
			return;
		}		
	}
	if(pinNumber == 4)
		PCintPort::detachInterrupt(4);
	if(pinNumber == 10)
		PCintPort::detachInterrupt(10);
}

void sendIO(bool analogOrDigital, uint8_t pinNumber)
{
	if(!startSMSSend(3))
	{
		if(analogOrDigital)
		{
			if(digitalRead(pinNumber))
				GSM.println("ON");
			else
				GSM.println("OFF");
		}
		else
			GSM.println(analogRead(pinNumber),DEC);
		if(!sim900.sendSMS())
		{
			if(analogOrDigital)
				digitalReadPin = 0;
			else
				analogReadPin = 0;
		}
	}
	sim900.gsmSleepMode(2);
}



void singlePulse(uint8_t pinNumber)
{
	digitalWrite(pinNumber,LOW);
	delay(EEPROM.read(IOSINGLEPULSETIME) * 10);
	digitalWrite(pinNumber,HIGH);
}

void doublePulse(uint8_t pinNumber)
{
	digitalWrite(pinNumber,LOW);
	delay(EEPROM.read(IODOUBLEPULSETIME1) * 10);
	digitalWrite(pinNumber,HIGH);
	delay(EEPROM.read(IODOUBLEPULSETIME2) * 10);
	digitalWrite(pinNumber,LOW);
	delay(EEPROM.read(IODOUBLEPULSETIME3) * 10);
	digitalWrite(pinNumber,HIGH);
}

