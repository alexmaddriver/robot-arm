import processing.serial.*;
import g4p_controls.*;

int GRID_STEP = 10;

int a1 = 10;
int a2 = 10;

float newXc = 20, newYc = 0;
float oldXc = 20, oldYc = 0;
float[] oldJoints = {0, 0};
boolean newPositionRequested = true;

GSlider j1Slider;
GSlider j2Slider;
Serial serial;

void setup() {
  size(displayWidth/2, displayHeight/2);
  frameRate(10);

  println(Serial.list());
  serial = new Serial(this, Serial.list()[1], 9600);

  j1Slider = new GSlider(this, 55, 80, 200, 100, 10);
  j1Slider.setLimits(0, 0, 360);
  j1Slider.setShowValue(true);
  j1Slider.setShowLimits(true);

  j2Slider = new GSlider(this, 55, 120, 200, 140, 10);
  j2Slider.setLimits(0, 0, 360);
  j2Slider.setShowValue(true);
  j2Slider.setShowLimits(true);
}

void draw() {
  if (newPositionRequested) {
    background(255);  
    drawGrid();
    drawWorkspace();

    drawArm(oldJoints);
    
    float stepsNumber = ceil (sqrt(sq(newXc-oldXc) + sq(newYc-oldYc)) / 1);
    println("stepsNumber=" + stepsNumber);
    
    for (int step=1; step<=stepsNumber; step++) {
      float curXc = oldXc + (newXc-oldXc)/stepsNumber*step;
      float curYc = oldYc + (newYc-oldYc)/stepsNumber*step;
      println("curXc=" + curXc + ", curYc=" + curYc);

      float[] newJoints = calcConfigurationPoint(curXc, curYc);

      float moveTime = ceil (max(abs(newJoints[0]-oldJoints[0]), abs(newJoints[1]-oldJoints[1]))); 
      for (int t=1; t<=moveTime; t++) {
        float q1 = oldJoints[0] + (newJoints[0] - oldJoints[0])*t/moveTime;
        float q2 = oldJoints[1] + (newJoints[1] - oldJoints[1])*t/moveTime;
      
        drawEndEffectorTrace(q1, q2);
      }
      oldJoints = newJoints;
      
      if (step == stepsNumber)
        drawArm(newJoints);
    }
    
    oldXc = newXc;
    oldYc = newYc;  
    newPositionRequested = false;
  }
}

float[] calcConfigurationPoint(float x, float y){
  float D = (x*x + y*y - a1*a1 - a2*a2) / (2*a1*a2);  
  float q2 = degrees(atan2(sqrt(1 - D*D), D));  
  float q1 = degrees(atan2(y, x) - atan2(a2*sin(radians(q2)), a1+a2*cos(radians(q2))));
  
  println("calcConfigurationPoint(): x=" + x + ", y=" + y + ", D=" + D + ", q1=" + q1 + ", q2=" + q2);
  return new float[] {q1, q2};
}

void drawEndEffectorTrace(float q1, float q2){
  float x20 = a1*cos(radians(q1))*GRID_STEP + a2*cos(radians(q1+q2))*GRID_STEP;
  float y20 = a1*sin(radians(q1))*GRID_STEP + a2*sin(radians(q1+q2))*GRID_STEP;
  point(width/2 + x20, height/2 - y20);
  
  String command = (int)q1 + ":" + (int)q2 + ";";
  println(command);
  serial.write(command);
}

void drawArm(float[] joints) {
  float x10 = a1*cos(radians(joints[0]))*GRID_STEP;
  float y10 = a1*sin(radians(joints[0]))*GRID_STEP;

  float x20 = x10 + a2*cos(radians(joints[0]+joints[1]))*GRID_STEP;
  float y20 = y10 + a2*sin(radians(joints[0]+joints[1]))*GRID_STEP;
  drawArm(x10, y10, x20, y20);
}

void drawArm(float x10, float y10, float x20, float y20) {
  strokeWeight(2);
  stroke(#FF0000);
  
  float x0 = width/2;
  float y0 = height/2;

  line(x0, y0, x0 + x10, y0 - y10);

  stroke(#00FF00);
  line(x0 + x10, y0 - y10, x0 + x20, y0 - y20);
  strokeWeight(1);
} 

void mouseClicked() {
  float x0 = width/2;
  float y0 = height/2;
  
  newXc = (mouseX - x0) / GRID_STEP;
  newYc = (y0 - mouseY) / GRID_STEP;

  println ("newXc=" + newXc + ", newYc=" + newYc);  
  newPositionRequested = true;
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
//  if (slider == j1Slider)
//    theta1 = slider.getValueF();
//  if (slider == j2Slider)
//    theta2 = slider.getValueF();
}

void drawWorkspace(){
  noFill();
  float diameter = 2*(a1+a2)*GRID_STEP;
  ellipse(width/2, height/2, diameter, diameter);
  fill(#FFFFFF);
}

void drawGrid()
{
  strokeWeight(2);
  stroke(#0000FF);
  line(width/2, 0, width/2, height);
  line(0, height/2, width, height/2);
  strokeWeight(1);

  stroke(0);
  for (int i=1; i<25; i++)
  {
    line(width/2-GRID_STEP*i, 0, width/2-GRID_STEP*i, height);
    line(width/2+GRID_STEP*i, 0, width/2+GRID_STEP*i, height);

    line(0, height/2-GRID_STEP*i, width, height/2-GRID_STEP*i);
    line(0, height/2+GRID_STEP*i, width, height/2+GRID_STEP*i);
  }
}

void drawWorkspace(float theta1Start, float theta1End, float theta2Start, float theta2End){
  stroke(#FF0000);
  
  for (float theta1=theta1Start; theta1<=theta1End; theta1++){
    for (float theta2=theta2Start; theta2<=theta2End; theta2++){
      float x10 = a1*cos(radians(theta1))*GRID_STEP;
      float y10 = a1*sin(radians(theta1))*GRID_STEP;

      float x20 = x10 + a2*cos(radians(theta1+theta2))*GRID_STEP;
      float y20 = y10 + a2*sin(radians(theta1+theta2))*GRID_STEP;
      point(width/2 + x20, height/2 - y20);
    }
  }
}




