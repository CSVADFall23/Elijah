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
}

void draw() {
  /*
  The operatePixel function utilizes the fact that each pixel's
  data is stored as a 32-bit int. This int contains ARGB information
  and is not supposed to be treated as one number without parsing.
  By multiplying or adding to this number directly, we can get 
  unexpected results.
  */
  if (mousePressed) {
    if (mouseButton == LEFT) {
      IG.operatePixels(1.00005, Operation.MULT);
    }
    else if (mouseButton == RIGHT) {
      IG.operatePixels(0.9999, Operation.MULT);
    }
  }
  image(IG.getImage(), 0, 0); // draw the ImageGlitch to fill the canvas
}

void keyPressed() {
  if (keyCode == ENTER) {
    IG.restore();  // restore the ImageGlitch to original image
  }
  if (key == ' ') {  // saves canvas
    String newName = fileName + "_OperatePixelExample_" + int(random(9999)) + ".png";
    save(newName);
    println("Saved as " + newName);
  }
}
