import SimpleOpenNI.*;
import processing.opengl.*;
import processing.serial.*;

SimpleOpenNI kinect;
Serial myPort;

XnVSessionManager sessionManager;
XnVPointControl pointControl;
XnVCircleDetector circleDetector;

PFont font;
int mode = 0;
boolean handsTrackFlag = true;
PVector screenHandVec = new PVector();
PVector handVec = new PVector();
ArrayList<PVector> handVecList = new ArrayList<PVector>();
int handVecListSize = 30;
float rot;
float prevRot;
float rad;
float angle;
PVector centerVec = new PVector();
PVector screenCenterVec = new PVector();
int changeChannel;
int channelTime;

void setup(){
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableGesture();
  kinect.enableHands();
  
  sessionManager = kinect.createSessionManager("Wave", "RaiseHand");
  pointControl = new XnVPointControl();
  pointControl.RegisterPointCreate(this);
  pointControl.RegisterPointDestroy(this);
  pointControl.RegisterPointUpdate(this);
  
  circleDetector = new XnVCircleDetector();
  circleDetector.RegisterCircle(this);
  circleDetector.RegisterNoCircle(this);
  
  sessionManager.AddListener(circleDetector);
  sessionManager.AddListener(pointControl);
  
  size(kinect.depthWidth(), kinect.depthHeight());
  smooth();
  font = loadFont("SansSerif-12.vlw");
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void onPointCreate(XnVHandPointContext pContext){
  println("onPointCreate:");
  handsTrackFlag = true;
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.clear();
  handVecList.add(handVec.get());
}

void onPointDestroy(int nID){
  println("PointDestroy: " + nID);
  handsTrackFlag = false;
}

void onPointUpdate(XnVHandPointContext pContext){
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.add(0, handVec.get());
  if(handVecList.size() >= handVecListSize){
    handVecList.remove(handVecList.size()-1);
  }
}

void onCircle(float fTimes, boolean bConfident, XnVCircle circle){
  println("onCircle: " + fTimes + ", bConfident=" + bConfident);
  rot = fTimes;
  angle = (fTimes % 1.0f) * 2 * PI - PI/2;
  centerVec.set(circle.getPtCenter().getX(), circle.getPtCenter().getY(), handVec.z);
  kinect.convertRealWorldToProjective(centerVec, screenCenterVec);
  rad = circle.getFRadius();
  mode = 1;
}

void onNoCircle(float fTimes, int reason)
{
  println("onNoCircle: " + fTimes + ", reason= " + reason);
  mode = 0;
}

void draw(){
  background(0);
  kinect.update();
  kinect.update(sessionManager);
  image(kinect.rgbImage(), 0 , 0);
  
  switch(mode){
    case 0:
      checkSpeed();
      if(handsTrackFlag){drawHand();}
      break;
    
    case 1:
      volumeControl();
      break;
    
    case 2:
      channelChange(changeChannel);
      channelTime++;
      if(channelTime > 10){
        channelTime = 0;
        mode = 0;
      }
      break;
  }
}

void checkSpeed() {
  if (handVecList.size() > 1) {
    PVector vel = PVector.sub(handVecList.get(0), handVecList.get(1));
    if(vel.x > 50){
      mode = 2;
      changeChannel = 1;
    }else if(vel.x < -50){
      changeChannel = -1;
      mode = 2;
    }
  }
}

void channelChange(int sign) {
  String channelChange;
  pushStyle();
  if(sign == 1){
    stroke(255, 0, 0);
    fill(255, 0, 0);
    if(channelTime == 0)myPort.write(1);
    textAlign(LEFT);
    channelChange = "Next Channel";
  }else{
    stroke(0, 255, 0);
    fill(0, 255, 0);
    if(channelTime == 0)myPort.write(2);
    textAlign(RIGHT);
    channelChange = "Previous Channel";
  }
  
  strokeWeight(10);
  pushMatrix();
  translate(width/2, height/2);
  line(0,0,sign*200, 0);
  triangle(sign*200, 20, sign*200, -20, sign*250, 0);
  textFont(font, 20);
  text(channelChange, 0, 40);
  popMatrix();
  popStyle();
}
    
void volumeControl(){             
   String volumeText = "You can now change the volume";
   fill(150);
   ellipse(screenCenterVec.x, screenCenterVec.y, 2*rad, 2*rad);
   fill(255);
   
   if(rot>prevRot){
     fill(0, 0, 255);
     volumeText = "Volume Level Up";
     myPort.write(3);
   }else{
     fill(0, 255, 0);
     volumeText = "Volume Level Down";
     myPort.write(4);
   }
   
   prevRot = rot;
   text(volumeText, screenCenterVec.x, screenCenterVec.y);
   line(screenCenterVec.x, screenCenterVec.y, screenCenterVec.x+rad*cos(angle), screenCenterVec.y+rad*sin(angle));
}  
    
void drawHand(){
  stroke(255, 0, 0);
  pushStyle();
  strokeWeight(6);
  kinect.convertRealWorldToProjective(handVec, screenHandVec);
  point(screenHandVec.x, screenHandVec.y);
  popStyle();
  
  noFill();
  
  Iterator itr = handVecList.iterator();
  
  beginShape();
  while(itr.hasNext()){
    PVector p = (PVector) itr.next();
    PVector sp = new PVector();
    kinect.convertRealWorldToProjective(p, sp);
    vertex(sp.x, sp.y);
  }
  endShape();
}
