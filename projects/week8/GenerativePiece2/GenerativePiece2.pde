int barMin = 20;
int barMax = 25;
int spaceMin = 15;
int spaceMax = 60;
int slantNum = 8;
int thickness = 100;
int minThinStripes = 2;
int maxThinStripes = 7;
int minThickStripes = 4;
int maxThickStripes = 15;

IntList colors = new IntList();
int linesColor;
int altColor;

void setup() {
  size(600, 600);
  colorMode(RGB, 255);
  
  colors.push(color(225, 22, 11));  //bright red
  colors.push(color(136, 16, 12));  //dark red
  colors.push(color(246, 116, 12));  //orange
  colors.push(color(243, 174, 63));  //yellow
  colors.push(color(170, 205, 27));  //lime
  colors.push(color(54, 68, 4));    //dark green
  colors.push(color(2, 108, 121));  //dark teal
  
  linesColor = color(255, 255, 255);
  altColor = color(255, 255, 210);

  background(0);
  
  noStroke();
  for (int i = 0; i < slantNum; i++) {
    if (random(1) < 0.5) {
      int startingPoint = (int)random(height-thickness);
      if (random(1) < 0.5) {
        if (random(1) < 0.5) {
          segmentedQuad(0, startingPoint, 0, startingPoint+thickness, width, startingPoint+width, width, startingPoint+width+thickness, (int)random(minThinStripes, maxThinStripes));
        }
        else {
          segmentedQuad(0, startingPoint, width, startingPoint+width, 0, startingPoint+thickness, width, startingPoint+thickness+width, (int)random(minThickStripes, maxThickStripes));
        }
      }
      else {
        if (random(1) < 0.5) {
          segmentedQuad(0, startingPoint, 0, startingPoint+thickness, width, startingPoint-width, width, startingPoint-width+thickness, (int)random(minThinStripes, maxThinStripes));
        }
        else {
          segmentedQuad(0, startingPoint, width, startingPoint-width, 0, startingPoint+thickness, width, startingPoint+thickness-width, (int)random(minThickStripes, maxThickStripes));
        }
      }
    }
    else {
      int startingPoint = (int)random(width-thickness);
      if (random(1) < 0.5) {
        if (random(1) < 0.5) {
          segmentedQuad(startingPoint, 0, startingPoint+thickness, 0, startingPoint+height, height, startingPoint+thickness+height, height, (int)random(minThinStripes, maxThinStripes));
        }
        else {
          segmentedQuad(startingPoint, 0, startingPoint+height, height, startingPoint+thickness, 0, startingPoint+thickness+height, height, (int)random(minThickStripes, maxThickStripes));
        }
      }
      else {
        if (random(1) < 0.5) {
        segmentedQuad(startingPoint, 0, startingPoint+thickness, 0, startingPoint-height, height, startingPoint+thickness-height, height, (int)random(minThinStripes, maxThinStripes));
        }
        else {
        segmentedQuad(startingPoint, 0, startingPoint-height, height, startingPoint+thickness, 0, startingPoint+thickness-height, height, (int)random(minThickStripes, maxThickStripes));
        }
      }
    }
  }
      
  push();
  noStroke();
  int currentX = 0;
  boolean bar = true;
  while(currentX <= width) {
    if (bar) {
      int w = (int)random(barMin, barMax);
      float randAmt = random(1);
      color c = lerpColor(linesColor, altColor, randAmt);
      fill(c);
      rect(currentX, 0, w, height);
      currentX += w;
      bar = false;
    }
    else {
      int w = (int)random(spaceMin, spaceMax);
      currentX += w;
      bar = true;
    }
  }
  pop();
}

void segmentedQuad(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, int subdivs) {
  for (int i = 0; i < subdivs; i++) {
    int index = (int)random(colors.size());
    fill(colors.get(index));
    float newx1 = lerp(x1, x2, i/(float)subdivs);
    float newy1 = lerp(y1, y2, i/(float)subdivs);
    float newx2 = lerp(x1, x2, (i+1)/(float)subdivs);
    float newy2 = lerp(y1, y2, (i+1)/(float)subdivs);
    float newx3 = lerp(x3, x4, (i+1)/(float)subdivs);
    float newy3 = lerp(y3, y4, (i+1)/(float)subdivs);
    float newx4 = lerp(x3, x4, i/(float)subdivs);
    float newy4 = lerp(y3, y4, i/(float)subdivs);
    quad(newx1, newy1, newx2, newy2, newx3, newy3, newx4, newy4);
  }
}

void draw() {
}

void keyPressed() {
  if (key == ' ') {  // saves canvas
    String name = "GenerativePiece2_" + int(random(9999)) + ".png";
    save(name);
    println("Saved as " + name);
  }
}
