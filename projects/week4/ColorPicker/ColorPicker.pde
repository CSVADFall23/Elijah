PImage img;
String fileName = "Forest.jpeg";
int mouseRange = 100;
int sizeMin = 20;
int sizeMax = 70;
IntList palette = new IntList();
boolean dragging = false;
boolean previousDrag = false;
int selectedPalette;
int dragX;
int dragY;

void settings() {
  img = loadImage(fileName);
  while(img.height > 900 || img.width > 1800) {
    img.resize(int(img.width*0.75), int(img.height*0.75));
  }
  size(img.width, img.height+100);
}

void setup() {
  frameRate(30);
  colorMode(HSB, 255);
  
  background(0);
  image(img, 0, 0);
}

void draw() {
  if (mousePressed && mouseButton == 37) {
    if (mouseY < height-100 && !dragging) {
      colorFromImage();
    }
    if (mouseY >= height-100) {
      dragPalette();
    }
  }
  else {
    dragging = false;
  }
  if (previousDrag && !dragging) {
    int otherIndex = getPaletteIndex();
    if (selectedPalette != otherIndex) {
      int temp = palette.get(selectedPalette);
      palette.set(selectedPalette, palette.get(otherIndex));
      palette.set(otherIndex, temp);
    }
  }
  previousDrag = dragging;
  drawPalette();
}

void mousePressed() {
  if (mouseButton == 39) {
    if (mouseY < height-100) {
      selectColor();
    } 
    else {
      int index = getPaletteIndex();
      palette.remove(index);
    }
  }
}

void colorFromImage() {
  int x = mouseX + (int)random(-mouseRange, mouseRange);
  int y = mouseY + (int)random(-mouseRange, mouseRange);
  int size = (int)random(sizeMin, sizeMax);
  
  push();
  color c = img.get(x, y);
  fill(c);
  noStroke();
  circle(x, y, size);
  pop();
}

void selectColor() {
  color c = get(mouseX, mouseY);
  palette.push(c);
}

void drawPalette() {
  if (palette.size() > 0) {
    float w = width/palette.size();
    push();
    noStroke();
    for (int i = 0; i < palette.size(); i++) {
      fill(palette.get(i));
      rect(i*w, height-100, w, 100);
    }
    pop();
  }
}

void dragPalette() {
  if (!dragging) {
    selectedPalette = getPaletteIndex();
    dragX = mouseX;
    dragY = mouseY;
    dragging = true;
  }
  
}

int getPaletteIndex() {
  if (palette.size() > 0) {
    float w = width/palette.size();
    for (int i = 1; i < palette.size()+1; i++) {
      if (mouseX < i*w) {
        int index = i-1;
        return index;
      }
    }
  }
  return 0;
}
