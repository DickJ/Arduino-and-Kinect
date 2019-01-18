import SimpleOpenNI.*;
import processing.serial.*;
SimpleOpenNI kinect;
Serial myPort;

PVector handVec = new PVector();
PVector mapHandVec = new PVector();
color handPointCol = color(255, 0, 0);
int photoVal;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableGesture();
  kinect.enableHands();
  kinect.addGesture("Wave");
  size(kinect.depthWidth(), kinect.depthHeight());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  println("onRecognizeGesture - strGesture: " + strGesture + ", idPosition: " + idPosition + ", endposition:" + endPosition);
  kinect.removeGesture(strGesture);
  kinect.startTrackingHands(endPosition);
}

void onCreateHands(int handId, PVector pos, float time)
{
  println("onCreateHands - handId: " + handId + ", pos: " + pos + ", time: " + time);
  handVec = pos;
  handPointCol = color(0, 255, 0);
}

void onUpdateHands(int handId, PVector pos, float time)
{
  println("onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time);
  handVec = pos;
}

void draw(){
  kinect.update();
  kinect.convertRealWorldToProjective(handVec, mapHandVec);
 
  if (photoVal<500){
    image(kinect.rgbImage(), 0 , 0);
  }else{
    image(kinect.depthImage(), 0, 0);
  }
  
  image(kinect.depthImage(), 0, 0);
  strokeWeight(10);
  stroke(handPointCol);
  point(mapHandVec.x, mapHandVec.y);
  
  myPort.write('S');
  myPort.write(int(255*mapHandVec.x/width));
  myPort.write(int(255*mapHandVec.y/height));
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n');
  if(inString != null) {
    inString = trim(inString);
    photoVal = int(inString);
  } else {
    println("No data to display");
  }
}
