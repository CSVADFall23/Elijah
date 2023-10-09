import processing.pdf.*;
//int xNum = 138;
//int yNum = 107;
int xNum = 110;
int yNum = 85;
float length = 4;
float noiseSize = 0.004;

void setup() {
  size(1100, 850);
  
  beginRecord(PDF, "PlotterNoise"+(int)random(999)+".pdf");
  for (int k = 0; k < 6; k++) {
    for (int i = -10; i < xNum+10; i++) {
      for (int j = -10; j < yNum+10; j++) {
        int x = i*width/xNum;
        int y = j*height/yNum;
        float angle = TWO_PI*noise(x*noiseSize, y*noiseSize);
        line(x, y, x+length*cos(angle), y+length*sin(angle));
      }
    }
    translate(width/2, height/2);
    rotate(PI/40);
    translate(-width/2, -height/2);
  }
  endRecord();
}
