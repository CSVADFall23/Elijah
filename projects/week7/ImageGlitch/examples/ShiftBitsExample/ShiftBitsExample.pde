import ImageGlitch.*;  // import image glitch library

String fileName = "mountains"; // name of file to import
String fileType = "jpeg";  // file type to import
PImage img;

ImageGlitch IG;  // name of ImageGlitch variable

void settings() {
  img = loadImage(fileName + "." + fileType);  // import base image
  size(img.width, img.height);  // set window to image size
}

void setup() {
  IG = new ImageGlitch(img);  // create new ImageGlitch from image
  image(IG.getImage(), 0, 0);  // draw ImageGlitch to fill the canvas
}

void draw() {
}

void mousePressed() {
  /*
  The shiftBits function treats the entire pixel array as one long 
  bit string. Bit shifting in this way causes pixel values to slide
  into each other. The boolean argument toggles ignoring the alpha
  value, which makes a noticable difference in results.
  */
  if (mouseButton == LEFT) {
    IG.shiftBits(1, true);  //shift once to the right ignoring the alpha channel
  }
  else if (mouseButton == RIGHT) {
    IG.shiftBits(1, false);  //shift once to the right
  }
  image(IG.getImage(), 0, 0);
}

void keyPressed() {
  if (keyCode == ENTER) {
    IG.restore();  // restore the ImageGlitch to original image
  }
  if (key == ' ') {  // saves canvas
    String newName = fileName + "_ShiftBitsExample_" + int(random(9999)) + ".png";
    save(newName);
    println("Saved as " + newName);
  }
}
