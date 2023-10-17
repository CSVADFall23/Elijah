#include <NintendoExtensionCtrl.h>
#include <Adafruit_NeoPixel.h>

#define LED_PIN    2
#define DIMENSION 16
#define LED_COUNT 256

Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
Nunchuk nchuk;

int joystickXMin = 34;
int joystickXMax = 232;
int joystickYMin = 31;
int joystickYMax = 224;
int rotXMin = 280;
int rotXMax = 700;
int rotYMin = 290;
int rotYMax = 680;
float cursorSpeed = 0.3;

float joystickX;
float joystickY;
float rotX;
float rotY;
float cursorLoc[2];
int index;

void setup() {
  Serial.begin(115200);

  nchuk.begin();
  if (!nchuk.connect()) {
    Serial.println("Nunchuk not detected.");
    delay(1000);
  }

  strip.begin();     
  strip.clear();
  strip.show();     
  strip.setBrightness(25);

  cursorLoc[0] = DIMENSION/2-1;
  cursorLoc[1] = DIMENSION/2-1;

}

void loop() {
  nchuk.update();
  processData();
  printData();

  if (abs(joystickX) > 0.05) {
  cursorLoc[0] = constrain(cursorLoc[0] + joystickX*cursorSpeed, 0, DIMENSION-0.001);
  }
  if (abs(joystickY) > 0.05) {
  cursorLoc[1] = constrain(cursorLoc[1] + joystickY*cursorSpeed, 0, DIMENSION-0.001);
  }

    if ((int)cursorLoc[1]%2 == 0) {
      index = (int)cursorLoc[0] + (int)cursorLoc[1]*DIMENSION;
    } else {
      index = DIMENSION-1-(int)cursorLoc[0] + (int)cursorLoc[1]*DIMENSION;
    }
    if (!nchuk.buttonC()) {
      strip.clear();
    }
    int sat = 255; if (rotY > 0.75) { sat = 0; }
    strip.setPixelColor(index, strip.ColorHSV(rotX * 65536L, sat, 255));
    strip.show();
}

void processData() {
  joystickX = ((nchuk.joyX()-joystickXMin)/(float)(joystickXMax-joystickXMin))*2-1;
  joystickY = ((nchuk.joyY()-joystickYMin)/(float)(joystickYMax-joystickYMin))*2-1;
  rotX = (nchuk.accelX()-rotXMin)/(float)(rotXMax-rotXMin);
  rotY = (nchuk.accelY()-rotYMin)/(float)(rotYMax-rotYMin);
}

void printData() {
  Serial.print("X: "); Serial.print(rotX);
  Serial.print(" \tY: "); Serial.print(rotY); 
  // Serial.print(" \tZ: "); Serial.println(nchuk.accelZ()); 

  Serial.print("Joy: ("); 
  Serial.print(joystickX);
  Serial.print(", "); 
  Serial.print(joystickY);
  Serial.println(")");

  Serial.print("Button: "); 
  if (nchuk.buttonZ()) Serial.print(" Z "); 
  if (nchuk.buttonC()) Serial.print(" C "); 
  Serial.println();

  Serial.print("CursorLoc: ("); 
  Serial.print(cursorLoc[0]);
  Serial.print(", "); 
  Serial.print(cursorLoc[1]);
  Serial.println(")");
}