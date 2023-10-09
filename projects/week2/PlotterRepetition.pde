import processing.pdf.*;
import controlP5.*;
ControlP5 cp5;

ArrayList<int[]> vertices = new ArrayList<int[]>();
boolean drawing = true;
int repetitions = 12;
float angle = 0.5;
boolean grid = false;
int gridXSize = 10;
int gridYSize = 10;
float gridXScale = 0.1;
float gridYScale = 0.1;
float gridRotation = 0;
int[] rotationPoint = new int[2];
boolean saveOneFrame = false;

void setup() {
  size(1100, 850);
  stroke(0);
  noFill();
  strokeWeight(1);
  strokeCap(ROUND);
  
  cp5 = new ControlP5(this);
  
  cp5.addToggle("grid")
   .setPosition(25, height-65)
   .setSize(20, 20)
   .setValue(false);
  
  cp5.addSlider("repetitions")
    .setPosition(75, height-80)
    .setRange(2, 80)
    .setSize(175, 20);
    
   cp5.addSlider("angle")
     .setPosition(75, height-50)
     .setRange(0, 1)
     .setSize(175, 20);
   
   cp5.addSlider("gridXSize")
     .setPosition(75, height-80)
     .setRange(2, 30)
     .setSize(150, 20);
     
   cp5.addSlider("gridYSize")
     .setPosition(75, height-50)
     .setRange(2, 30)
     .setSize(150, 20);
     
   cp5.addSlider("gridXScale")
     .setPosition(300, height-80)
     .setRange(0, 0.5)
     .setSize(150, 20);
     
   cp5.addSlider("gridYScale")
     .setPosition(300, height-50)
     .setRange(0, 0.5)
     .setSize(150, 20);
     
   cp5.addSlider("gridRotation")
     .setPosition(525, height-65)
     .setRange(0, 1)
     .setSize(150, 20);

    rotationPoint[0] = width/2;
    rotationPoint[1] = height/2;
}

void draw() {
  background(255);
  
  if (drawing) {
    drawCurve();
    drawDots();
  } 
  else {
    if (saveOneFrame) {
      beginRecord(PDF, "plotter"+int(random(9999))+".pdf");
    }
    if (grid) {
      drawGrid();
    }
    else {
      drawRadial();
    }
    if (saveOneFrame) {
      endRecord();
      saveOneFrame = false;
    }
  }
  
  if (mousePressed && mouseButton == RIGHT) {
    rotationPoint[0] = mouseX;
    rotationPoint[1] = mouseY;
  }
  
  if (keyPressed) {
    int xMove = 0;
    int yMove = 0;
    boolean update = false;
    if (keyCode == 37) {
      xMove += -1;
      update = true;
    }
    if (keyCode == 38) {
      yMove += -1;
      update = true;
    }
    if (keyCode == 39) {
      xMove += 1;
      update = true;
    }
    if (keyCode == 40) {
      yMove += 1;
      update = true;
    }
    if (update) {
      ArrayList<int[]> newList = new ArrayList<int[]>();
      for (int i = 0; i < vertices.size(); i++) {
        int[] newPair = new int[2];
        newPair[0] = vertices.get(i)[0]+xMove;
        newPair[1] = vertices.get(i)[1]+yMove;
        newList.add(newPair);
      }
      vertices = newList;
      rotationPoint[0] = rotationPoint[0]+xMove;
      rotationPoint[1] = rotationPoint[1]+yMove;
    }
  }
  
  setUIVisibility();
}

void drawCurve() {
  if (vertices.size() > 0) {
    beginShape();
    curveVertex(vertices.get(0)[0], vertices.get(0)[1]);
    for (int i = 0; i < vertices.size(); i++) {
      curveVertex(vertices.get(i)[0], vertices.get(i)[1]);
    }
    curveVertex(vertices.get(vertices.size()-1)[0], vertices.get(vertices.size()-1)[1]);
    endShape();
  }
}

void drawRadial() {
  for (int i = 0; i < repetitions; i++) {
    push();
    translate(rotationPoint[0], rotationPoint[1]);
    rotate(i*TWO_PI*angle/repetitions);
    translate(-rotationPoint[0], -rotationPoint[1]);
    drawCurve();
    pop();
  }
}

void drawGrid() {
  push();
  strokeWeight(1/min(gridXScale, gridYScale));
  for (int i = -gridXSize; i < 2*gridXSize; i++) {
    for (int j = -gridYSize; j < 2*gridYSize; j++) {
      push();
      translate(width/2, height/2);
      rotate(gridRotation*TWO_PI);
      translate(-width/2, -height/2);
      translate(i*width/gridXSize, j*height/gridYSize);
      scale(gridXScale, gridYScale);
      drawCurve();
      pop();
    }
  }
  pop();
}

void drawDots() {
  push();
  noStroke();
  fill(255, 0, 0);
  circle(rotationPoint[0], rotationPoint[1], 5);
  if (vertices.size() > 0) {
    fill(0, 200, 0);
    circle(vertices.get(0)[0], vertices.get(0)[1], 5);
  }
  pop();
}

void setUIVisibility() {
  cp5.getController("grid").setVisible(!drawing);
  cp5.getController("repetitions").setVisible(!drawing && !grid);
  cp5.getController("angle").setVisible(!drawing && !grid);
  cp5.getController("gridXSize").setVisible(!drawing && grid);
  cp5.getController("gridYSize").setVisible(!drawing && grid);
  cp5.getController("gridXScale").setVisible(!drawing && grid);
  cp5.getController("gridYScale").setVisible(!drawing && grid);
  cp5.getController("gridRotation").setVisible(!drawing && grid);
}

void mousePressed() {  
  if (drawing && mouseButton == LEFT) {
      int[] newPair = new int[2];
      newPair[0] = mouseX;
      newPair[1] = mouseY;
      vertices.add(newPair);
  }
  if (!drawing && mouseButton == LEFT) {
    saveOneFrame = true;
    print("saved");
  }
}

void keyPressed() {
  if (key == ENTER) {
    drawing = !drawing;
  } 
  if (drawing && vertices.size() > 0) {
    if (keyCode == 91) {
      vertices.remove(0);
    }
    else if (keyCode == 93){
      vertices.remove(vertices.size()-1);
    }
  }
}
