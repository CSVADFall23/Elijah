int numRows = 3;
int backgroundMin = 150;
int backgroundMax = 170;
int rowSpaceMin = 70;
int rowSpaceMax = 90;
int rowBoxMin = 20;
int rowBoxMax = 50;

IntList colors;

void setup() {
  size(600, 600);
  colorMode(RGB, 255);
  noStroke();
  
  colors = new IntList();
  colors.push(color(255, 96, 69));  //red-orange
  colors.push(color(253, 155, 2));  //orange
  colors.push(color(252, 238, 1));  //yellow
  colors.push(color(0, 196, 176));  //teal
  colors.push(color(21, 104, 220));  //blue
  colors.push(color(181, 6, 213));  //purple
  colors.push(color(255, 12, 190));  //magenta
  
  background(0);
  
  int currentX = 0;
  while(currentX <= width) {
    int w = (int)random(backgroundMin, backgroundMax);
    int index = (int)random(colors.size());
    color c = colors.get(index);
    fill(c);
    rect(currentX, 0, w, height);
    currentX += w;
  }
  for (int i = 0; i < numRows; i++) {
    int y = i*height/numRows;
    currentX = 0;
    boolean box = true;
    if (random(1) < 0.5) {
      box = false;
    }
    while(currentX <= width) {
      if (box) {
        int w = (int)random(rowBoxMin, rowBoxMax);
        gradientRect(currentX, y, w, height/numRows);
        currentX += w;
        box = false;
      }
      else {
        int w = (int)random(rowSpaceMin, rowSpaceMax);
        currentX += w; 
        box = true;
      }
    }
  }
  
}

void gradientRect(int x, int y, int w, int h) {
  color c1, c2, c3, c4;
  int index1 = (int)random(colors.size());
  int index2 = (int)random(colors.size());
  c1 = colors.get(index1);
  c2 = colors.get(index2);
  c3 = c1;
  float rand = random(1);
  if (rand < 0.5) {
    c4 = c2;
  }
  else if (rand < 0.7) {
    c4 = c1;
  }
  else {
    int index3 = (int)random(colors.size());
    c4 = colors.get(index3);
  }
  loadPixels();
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      if (i+x >= 0 && i+x < width && j+y >= 0 && j+y < height) {
        color inter1 = lerpColor(c1, c2, i/(float)w);
        color inter2 = lerpColor(c3, c4, i/(float)w);
        color inter3 = lerpColor(inter1, inter2, j/(float)h);
        int index = (y+j)*width+x+i;
        pixels[index] = inter3;
      }
    }
  }
  updatePixels();
}

void draw() {
}

void keyPressed() {
  if (key == ' ') {  // saves canvas
    String name = "GenerativePiece3_" + int(random(9999)) + ".png";
    save(name);
    println("Saved as " + name);
  }
}
