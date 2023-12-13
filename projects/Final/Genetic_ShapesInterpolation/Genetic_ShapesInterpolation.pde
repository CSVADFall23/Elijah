import java.util.*;

PImage img1;
PImage img2;
PImage img3;
PImage img4;
PImage testImg;
PGraphics testCanvas;
Population population;
int round = 0;

int difMax;
int selectCount;
int randomCount;
int geneSize;

String fileName1 = "ElijahHeadshot.png";
String fileName2 = "AuroraPicture1.png";
String fileName3 = "MATLogo.png";
String fileName4 = "SyndeySunset1.png";
int populationSize = 100;
int numShapes = 120;
int numVertices = 3;
float mutationChance = 0.015;
float mutationAmount = 0.15;
float selectionCutoff = 0.15;
int testRes = 64;
boolean displayRef = true;

void setup() {
  size(512, 512);
  
  img1 = loadImage(fileName1);
  img1.resize(testRes, testRes);
  img2 = loadImage(fileName2);
  img2.resize(testRes, testRes);
  img3 = loadImage(fileName3);
  img3.resize(testRes, testRes);
  img4 = loadImage(fileName4);
  img4.resize(testRes, testRes);

  colorMode(RGB, 1, 1, 1, 1);
  noStroke();
  
  testCanvas = createGraphics(testRes, testRes);
  testCanvas.beginDraw();
  testCanvas.colorMode(RGB, 1, 1, 1, 1);
  testCanvas.noStroke();
  testCanvas.endDraw();
  testImg = new PImage(testRes, testRes);
  
  difMax = width*height*3;
  selectCount = ceil(populationSize*selectionCutoff);
  randomCount = ceil(1/selectionCutoff);
  geneSize = 4+(2*numVertices);
  
  lerpImage();
  population = new Population();
  Individual best = population.bestChoice();
  best.display();
}

void draw() {
  lerpImage();
  population.naturalSelection();
  Individual best = population.bestChoice();
  best.display();
  
  if (displayRef) {
    image(testImg, 0, 0);
  }
  
  round++;
  println(population.averageFit() + "    " + round);
}

class Population {
  Individual[] genePool;
  
  Population() {
    genePool = new Individual[populationSize];
    for (int i = 0; i < populationSize; i++) {
      genePool[i] = new Individual();
    }
    sortByFitness();
  }
  
  void naturalSelection() {
    Individual[] newGenePool = new Individual[selectCount*randomCount];
    for (int i = 0; i < selectCount; i++) {
      Individual p1 = genePool[i];
      for (int j = 0; j < randomCount; j++) {
        int index = i;
        while (index == i) {
          index = (int)random(populationSize);
        }
        Individual p2 = genePool[index];
        newGenePool[i*randomCount+j] = new Individual(p1, p2);
      }
    }
    for (int i = 0; i < populationSize; i++) {
      genePool[i] = newGenePool[i];
    }
    for (int i = 0; i < populationSize; i++) {
      if (genePool[i] == null) {
        println(i);
      }
    }
    sortByFitness();
  }
  
  void sortByFitness() {
    Arrays.sort(genePool, new Comparator<Individual>() {
      @Override
      public int compare(Individual a, Individual b) {
        return Float.compare(b.fitness, a.fitness);
      }
    });
  }
  
  Individual bestChoice() {
    return genePool[0];
  }
  
  float averageFit() {
    float total = 0;
    for (Individual ind : genePool) {
      total += ind.fitness;
    }
    total /= populationSize;
    return total;
  }
}

class Individual {
  float[] genes;
  float fitness;
  
  Individual() {
    genes = new float[numShapes*geneSize];
    for (int i = 0; i < genes.length; i += geneSize) {
      genes[i] = random(1);
      genes[i+1] = random(1);
      genes[i+2] = random(1);
      genes[i+3] = max(random(1)*random(1), 0.2);
      float x = random(1);
      float y = random(1);
      for (int j = 0; j < numVertices; j++) {
        genes[i+4+2*j] = x+random(-0.5, 0.5);
        genes[i+4+2*j+1] = y+random(-0.5, 0.5);
      }
    }
    setFitness();
  }
  
  Individual(Individual p1, Individual p2) {
    genes = new float[numShapes*geneSize];
    for (int i = 0; i < genes.length; i += geneSize) {
      if (random(1) < 0.5) {
        for (int j = 0; j < geneSize; j++) {
          genes[i+j] = p1.genes[i+j];
        }
      }
      else {
        for (int j = 0; j < geneSize; j++) {
          genes[i+j] = p2.genes[i+j];
        }
      }
    }
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < mutationChance) {
        genes[i] += random(-mutationAmount, mutationAmount);
        genes[i] = constrain(genes[i], 0, 1);
      }
    }
    setFitness();
  }
  
  void setFitness() {
    testCanvas.beginDraw();
    display(testCanvas);
    testCanvas.endDraw();
    
    testCanvas.loadPixels();
    testImg.loadPixels();
    float total = 0;
    for (int i = 0; i < testImg.pixels.length; i++) {
      total += pow(red(testImg.pixels[i])-red(testCanvas.pixels[i]),2);
      total += pow(green(testImg.pixels[i])-green(testCanvas.pixels[i]),2);
      total += pow(blue(testImg.pixels[i])-blue(testCanvas.pixels[i]),2);
    }
    fitness = 1 - total/difMax;
  }
  
  void display(PGraphics canvas) {
    canvas.beginDraw();
    canvas.background(0);
    for (int i = 0; i < genes.length; i += geneSize) {
      canvas.fill(genes[i], genes[i+1], genes[i+2], genes[i+3]);
      canvas.beginShape();
      for (int j = 0; j < numVertices; j++) {
        canvas.vertex(canvas.width*genes[i+4+2*j], canvas.height*genes[i+4+2*j+1]);
      }
      canvas.endShape();
    }
    canvas.endDraw();
  }
  
  void display() {
    background(0);
    for (int i = 0; i < genes.length; i += geneSize) {
      fill(genes[i], genes[i+1], genes[i+2], genes[i+3]);
      beginShape();
      for (int j = 0; j < numVertices; j++) {
        vertex(width*genes[i+4+2*j], height*genes[i+4+2*j+1]);
      }
      endShape();
    }
  }
}

void lerpImage() {
  if (pmouseX == mouseX && pmouseY == mouseY && frameCount > 0) {
    return;
  }
  float lerpVal1 = mouseX/(float)width;
  float lerpVal2 = mouseY/(float)height;
  img1.loadPixels();
  img2.loadPixels();
  img3.loadPixels();
  img4.loadPixels();
  testImg.loadPixels();
  for (int i = 0; i < testImg.pixels.length; i++) {
    color c1 = img1.pixels[i];
    color c2 = img2.pixels[i];
    color ca = lerpColor(c1, c2, lerpVal1);
    color c3 = img3.pixels[i];
    color c4 = img4.pixels[i];
    color cb = lerpColor(c3, c4, lerpVal1);
    color c = lerpColor(ca, cb, lerpVal2);
    testImg.pixels[i] = c;
  }
  testImg.updatePixels();
}

void mouseClicked() {
  String name = "Genetic_ShapesInterpolation_" + (int)random(9999) + ".png";
  save(name);
  println("SAVED as " + name);
}
