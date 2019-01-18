int IRledPin = 13;

int VolUp[][13] = {{2380, 600, 1200, 620, 600, 1200, 620, 620, 1200, 620, 600, 600, 620}, 
                {560, 560, 540, 560, 560, 560, 540, 560, 540, 560, 560, 560, 0}};
int VolDn[][13] = {{2360, 1180, 1200, 620, 620, 1200, 620, 600, 1200, 600, 600, 620, 600},
                  {560, 560, 560, 540, 560, 540, 560, 560, 560, 560, 560, 560, 0}};
int ChUp[][13] = {{2360, 600, 620, 620, 620, 1200, 600, 620, 1200, 600, 620, 600, 620},
                 {560, 560, 540, 560, 540, 560, 560, 540, 560, 560, 560, 560, 0}};
int ChDn[][13] = {{2380, 1200, 620, 600, 620, 1200, 620, 620, 1200, 620, 620, 620, 620},
                  {560, 540, 560, 560, 540, 560, 540, 560, 540, 560, 540, 540, 0}};

void setup(){
  pinMode(IRledPin, OUTPUT);
  Serial.begin(9600);
}

void loop(){

  if(Serial.available()){
    char val = Serial.read();
    if(val == 1){
      sendCode(ChUp[0], ChUp[1]);
    } else if(val == 2){
      sendCode(ChDn[0], ChUp[1]);
    } else if(val == 3){
      sendCode(VolUp[0], VolUp[1]);
    } else if(val == 4){
      sendCode(VolDn[0], VolDn[1]);
    }
  }
}

void sendCode(int code[], int delays[]){
  for(int j=0; j<2; j++){
    for(int i=0; i<13; i++){
      pulseIR(code[i]);
      delayMicroseconds(delays[i]);
    }
    delayMicroseconds(65);
  }
}

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
