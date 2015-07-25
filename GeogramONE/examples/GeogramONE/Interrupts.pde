/****************************************
move variable bitmask
bit 0: Used with Sleep Timer
bit 1: Used with UDP Timer
bit 2: Used with SMS Timer
bit 3: Used in sleepForSeconds() function
bit 4 - 7: Unused 
****************************************/
void movement(){move = 0xFF;}

/*************************************************************	
	Procedure to check the status of the USB charging cable. 
	If the charging cable is plugged in  charge variable 
	will be a 0x01.  Unplugged, charge variable is 0x00.

**************************************************************/
void chargerStatus()
{
	delay(2);
	charge = digitalRead(PG_INT);
}

void ringIndicator(){call = 1;}
ISR(TIMER2_OVF_vect){sleepTimer2Overflow++;}
void charger(){charge |= 0x02;}
void lowBattery(){battery = 1;}
void d4Interrupt(){d4Switch = 0x01;}
void d10Interrupt(){d10Switch = 0x01;}
void d11Interrupt(){d11PowerSwitch = 0x01;}



