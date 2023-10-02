void setup() {
  size(500, 500);
  noLoop();
}

void draw() {
  background(255);
  
  push();
  fill(255, 255, 0);
  strokeWeight(4);
  circle(250, 250, 400);
  pop();
  
  push();
  fill(0);
  ellipse(175, 200, 50, 85);
  //ellipse(325, 200, 50, 80);
  pop();
  
  push();
  strokeWeight(10);
  noFill();
  arc(250, 280, 225, 225, PI/6, 5*PI/6);
  arc(325, 200, 60, 50, 0, PI);
  pop();
  
  push();
  fill(255, 0, 0, 50);
  noStroke();
  circle(115, 275, 75);
  circle(385, 275, 75);
  pop();
}
