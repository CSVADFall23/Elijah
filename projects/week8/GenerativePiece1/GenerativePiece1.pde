ArrayList<ArrayList<PVector>> gridPoints;

int gridSize = 40;
float linearBias = 0.8;
float horizontalBias = 0.4;
int linearReach = 5;
int curveReach = 3;
int repetitions = 3;

void setup() {
  size(600, 600);
  noLoop();
  
  gridPoints = new ArrayList<ArrayList<PVector>>();

  for (int i = 0; i <= gridSize; i++) {
    gridPoints.add(new ArrayList<PVector>());
    for (int j = 0; j <= gridSize; j++) {
      PVector point = new PVector(i*width/gridSize, j*height/gridSize);
      gridPoints.get(i).add(point);
    }
  }
}

void draw() {
  background(110);
  
  noStroke();
  fill(255);
  for (int i = 0; i <= gridSize; i++) {
    for (int j = 0; j <= gridSize; j++) {
      PVector point = gridPoints.get(i).get(j);
      circle(point.x, point.y, 2);
    }
  }
  
  noFill();
  stroke(255);
  for (int i = 0; i < repetitions; i++) {
    for (int j = 0; j <= gridSize; j++) {
      for (int k = 0; k <= gridSize; k++) {
        PVector point = gridPoints.get(j).get(k);
        if (random(1) < linearBias) {
          if (random(1) < horizontalBias) {
            float newX = int(random(-linearReach-1, linearReach+1))*width/gridSize+point.x;
            connectPoints(point, new PVector(newX, point.y));
          }
          else {
            float newY = int(random(-linearReach-1, linearReach+1))*height/gridSize+point.y;
            connectPoints(point, new PVector(point.x, newY));
          }
        }
        else {
          float newX = int(random(-curveReach-1, curveReach+1))*width/gridSize+point.x;
          float newY = int(random(-curveReach-1, curveReach+1))*height/gridSize+point.y;
          connectPoints(point, new PVector(newX, newY));
        }
      }
    }
  }
}

void connectPoints(PVector p1, PVector p2) {
  float interX1 = lerp(p1.x, p2.x, random(0, 0.5))+ random(-5, 5);
  float interY1 = lerp(p1.y, p2.y, random(0, 0.5))+ random(-5, 5);
  float interX2 = lerp(p1.x, p2.x, random(0.5, 1))+ random(-5, 5);
  float interY2 = lerp(p1.y, p2.y, random(0.5, 1))+ random(-5, 5);
  for (int i = 0; i < int(random(4, 10)); i++) {
    strokeWeight(random(0, 0.4));
    float ix1 = interX1 + random(-5, 5);
    float iy1 = interY1 + random(-5, 5);
    float ix2 = interX2 + random(-5, 5);
    float iy2 = interY2 + random(-5, 5);
    bezier(p1.x, p1.y, ix1, iy1, ix2, iy2, p2.x, p2.y);
  }
}

void keyPressed() {
  if (key == ' ') {  // saves canvas
    String name = "GenerativePiece1_" + int(random(9999)) + ".png";
    save(name);
    println("Saved as " + name);
  }
}
