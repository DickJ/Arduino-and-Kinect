// COM5
// This sketch will send out a Nikon D50 trigger signal (probably works with most Nikons)
// See the full tutorial at http://www.ladyada.net/learn/sensors/ir.html
// this code is public domain, please enjoy!
 
int IRledPin =  13;    // LED connected to digital pin 13
 
// The setup() method runs once, when the sketch starts
 
void setup()   {                
  // initialize the IR digital pin as an output:
  pinMode(IRledPin, OUTPUT);      
 
  Serial.begin(9600);
}
 
void loop()                     
{
  Serial.println("Sending IR signal");
 
  SendNikonCode();
 
  delay(5*1000);  // wait one minute (60 seconds * 1000 milliseconds)
}
 
// This procedure sends a 38KHz pulse to the IRledPin 
// for a certain # of microseconds. We'll use this whenever we need to send codes
void pulseIR(long microsecs) {
  // we'll count down from the number of microseconds we are told to wait
 
  cli();  // this turns off any background interrupts
 
  while (microsecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
   digitalWrite(IRledPin, HIGH);  // this takes about 3 microseconds to happen
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working
   digitalWrite(IRledPin, LOW);   // this also takes about 3 microseconds
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working
 
   // so 26 microseconds altogether
   microsecs -= 26;
  }
 
  sei();  // this turns them back on
}
 
void SendNikonCode() {
  // This is the code for my particular Nikon, for others use the tutorial
  // to 'grab' the proper code from the remote
  int pulses[]  = {2380, 600, 1200, 620, 600, 1200, 620, 620, 1200, 620, 600, 600, 620};
  int delays[] = {560, 560, 540, 560, 560, 560, 540, 560, 540, 560, 560, 560, 0};
  for(int i=0; i<13; i++){
    pulseIR(pulses[i]);
    delayMicroseconds(delays[i]);
  }
  
  delay(65); // wait 65 milliseconds before sending it again
  
  for(int i=0; i<13; i++){
    pulseIR(pulses[i]);
    delayMicroseconds(delays[i]);
  } 
}

/* 
int VolUpPulses = {2380, 600, 1200, 620, 600, 1200, 620, 620, 1200, 620, 600, 600, 620};
int VolUpDelays = {560, 560, 540, 560, 560, 560, 540, 560, 540, 560, 560, 560, 0};

int VolDnPulses = {2360, 1180, 1200, 620, 620, 1200, 620, 600, 1200, 600, 600, 620, 600};
int VolDnDelays = {560, 560, 560, 540, 560, 540, 560, 560, 560, 560, 560, 560, 0};

int ChUpPulses = {2360, 600, 620, 620, 620, 1200, 600, 620, 1200, 600, 620, 600, 620};
int ChUpDelays = {560, 560, 540, 560, 540, 560, 560, 540, 560, 560, 560, 560, 0};

int ChDnPulses = {2380, 1200, 620, 600, 620, 1200, 620, 620, 1200, 620, 620, 620, 620};
int ChDnDelays = {560, 540, 560, 560, 540, 560, 540, 560, 540, 560, 540, 540, 0};
*/
