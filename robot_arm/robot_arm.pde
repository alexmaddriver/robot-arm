import g4p_controls.*;


int GRID_STEP = 10;

float theta1 = 0;
float theta2 = 0;
int a1 = 10;
int a2 = 10;

float Xc, Yc;

GSlider j1Slider;
GSlider j2Slider;

void setup() {
  size(displayWidth/2, displayHeight/2);
  frameRate(10);

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
  background(255);  
  drawGrid();
  drawWorkspace();
  
  float D = (Xc*Xc + Yc*Yc - a1*a1 - a2*a2) / (2*a1*a2);
  
  theta2 = degrees(atan2(sqrt(1 - D*D), D));  
  theta1 = degrees(atan2(Yc, Xc) - atan2(a2*sin(radians(theta2)), a1+a2*cos(radians(theta2))));
  
  println("Xc=" + Xc + ", Yc=" + Yc + ", D=" + D + ", theta2=" + theta2 + ", theta1=" + theta1);
 
  drawArm();
}

void drawArm() {
  float x10 = a1*cos(radians(theta1))*GRID_STEP;
  float y10 = a1*sin(radians(theta1))*GRID_STEP;

  float x20 = x10 + a2*cos(radians(theta1+theta2))*GRID_STEP;
  float y20 = y10 + a2*sin(radians(theta1+theta2))*GRID_STEP;
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
  
  Xc = (mouseX - x0) / GRID_STEP;
  Yc = (y0 - mouseY) / GRID_STEP;
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == j1Slider)
    theta1 = slider.getValueF();
  if (slider == j2Slider)
    theta2 = slider.getValueF();
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
  
  for (theta1=theta1Start; theta1<=theta1End; theta1++){
    for (theta2=theta2Start; theta2<=theta2End; theta2++){
      float x10 = a1*cos(radians(theta1))*GRID_STEP;
      float y10 = a1*sin(radians(theta1))*GRID_STEP;

      float x20 = x10 + a2*cos(radians(theta1+theta2))*GRID_STEP;
      float y20 = y10 + a2*sin(radians(theta1+theta2))*GRID_STEP;
      point(width/2 + x20, height/2 - y20);
    }
  }
}




