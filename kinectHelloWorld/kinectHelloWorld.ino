int val, xVal, yVal;

void setup() {
  Serial.begin(9600);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
}

void loop(){
  if (Serial.available()>2) {
    val = Serial.read();
    if (val == 'S'){
      xVal = Serial.read();
      yVal = Serial.read();
    }
  }
  analogWrite(10, xVal);
  analogWrite(11, yVal);
}
