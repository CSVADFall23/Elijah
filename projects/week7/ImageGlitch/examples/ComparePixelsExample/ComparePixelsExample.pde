import ImageGlitch.*;  // import image glitch library

String fileName = "mountains"; // name of file to import
String fileType = "jpeg";  // file type to import
PImage img;

Value val = Value.RED;  // default value
Direction dir = Direction.LEFT;  // default direction
int threshold = 0;  // default threshold
boolean override = false;  // default override

ImageGlitch IG;  // name of ImageGlich variable

void settings() {
  img = loadImage(fileName + "." + fileType);  // import base image
  size(img.width, img.height);  // set window to image size
}

void setup() {
  IG = new ImageGlitch(img);  // create new ImageGlitch from image
}

void draw() {
  /*
  The comparePixels function compares each pixel to its neighbor.
  Which neighbor is determined by dir. The value being compared is
  determined by val. If the compared value is greating than the 
  original (plus an optional threshold), then the neighboring pixel
  takes the current pixels color. If override is false, then the
  current pixel will also take the neighbors color, effectively
  swapping them.
  */
  IG.comparePixels(val, dir, threshold, override);
  image(IG.getImage(), 0, 0);  // draw the ImageGlitch to fill the canvas
}

void keyPressed() {
  
  if (keyCode == ENTER) {
    IG.restore();  // restore the ImageGlitch to the original image
  }
  if (key == 'r') {  // sets value being compared
    val = Value.RED;
  }
  if (key == 'g') {
    val = Value.GREEN;
  }
  if (key == 'b') {
    val = Value.BLUE;
  }
  if (key == 'h') {
    val = Value.HUE;
  }
  if (key == 's') {
    val = Value.SAT;
  }
  if (key == 'v') {
    val = Value.BRI;
  }
  if (keyCode == UP) {  // sets direction neighbor is taken from
    dir = Direction.UP;
  }
  if (keyCode == DOWN) {
    dir = Direction.DOWN;
  }
  if (keyCode == LEFT) {
    dir = Direction.LEFT;
  }
  if (keyCode == RIGHT) {
    dir = Direction.RIGHT;
  }
  if (key == '/') {
    dir = Direction.RANDOM;  // direction can also be randomly chosen for each pixel
  }
  if (key == '0') {  //sets threshold for difference of compared values
    threshold = 0;
  }
  if (key == '1') {
    threshold = 10;
  }
  if (key == '2') {
    threshold = 20;
  }
  if (key == '3') {
    threshold = 30;
  }
  if (keyCode == SHIFT) {  // toggles override, whether the original pixel takes the neighboring color
    override = !override;
  }
  if (key == ' ') {  // saves canvas
    String newName = fileName + "_ComparePixelsExample_" + int(random(9999)) + ".png";
    save(newName);
    println("Saved as " + newName);
  }
}
