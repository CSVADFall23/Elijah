import controlP5.*;

ControlP5 cp5;
Population population;
ArrayList<Target> targets;
int round = 0;
int targetSize = 20;
boolean started = false;
boolean draggingStart = false;
int frameStart;
PVector startingPos = new PVector(400, 400);

int popSize = 100;
int lifespan = 700;
float mutateChance = 0.01;
float maxSpeed = 4;
int digAmount = 6;
int brightenAmt = 1;
int reDigAmount = 1;
boolean digTwice = true;
boolean bounce = false;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 255, 255);
  noStroke();
  frameRate(1000);
  
  background(0, 0, 255, 255);
  
  targets = new ArrayList<Target>();
  for (int i = 0; i < 3; i++) {
    targets.add(new Target((int)random(width), (int)random(height)));
  }
  
  createUI();
}

void draw() {
  if (started) {
    if ((frameCount-frameStart)%lifespan == 0 && (frameCount-frameStart) > 0) {
      population.evaluate();
      population = new Population(population);
      brighten();
      
      round++;
      println(round);
    }
    
    population.move();
    population.display();
  }
  else {
    background(0);
    for (Target t : targets) {
      if (t.dragging) {
        t.place(mouseX, mouseY);
      }
      t.display();
    }
    if (draggingStart) {
      startingPos = new PVector(mouseX, mouseY);
    }
    fill(240, 255, 255);
    circle(startingPos.x, startingPos.y, targetSize);
    updateValues();
  }
}

void startButton() {
  started = true;
  background(360);
  frameStart = frameCount+1;
  population = new Population();
  hideUI();
}

void brighten() {
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    color c = pixels[i];
    int h = (int)hue(c);
    int s = (int)saturation(c);
    int b = (int)brightness(c);
    b = min(255, b+brightenAmt);
    pixels[i] = color(h, s, b);
  }
  updatePixels();
}

class Target {
  PVector pos;
  boolean dragging;
  
  Target(int x, int y) {
    pos = new PVector(x, y);
    dragging = false;
  }
  
  void place(int x, int y) {
    pos.x = x;
    pos.y = y;
  }
  
  void display() {
    fill(0, 255, 255);
    circle(pos.x, pos.y, targetSize);
  }
  
  void update() {
    pos.x = mouseX;
    pos.y = mouseY;
  }
}

class Population {
  ArrayList<Individual> genePool = new ArrayList<Individual>();
  
  Population() {
    for (int i = 0; i < popSize; i++) {
      genePool.add(new Individual());
    }
  }
  
  Population(Population previous) {
    genePool = new ArrayList<Individual>();
    ArrayList<Individual> matingPool = new ArrayList<Individual>();
    for (Individual ind : previous.genePool) { 
      int poolNum = (int)(ind.fitness*100);
      for (int i = 0; i < poolNum; i++) {
        matingPool.add(ind);
      }
    }
    for (int i = 0; i < popSize; i++) {
      Individual p1 = matingPool.get((int)random(matingPool.size()));
      Individual p2 = matingPool.get((int)random(matingPool.size()));
      genePool.add(new Individual(p1, p2));
    }
  }
  
  void evaluate() {
    float maxFit = 0;
    for (Individual ind : genePool) {
      ind.evaluate();
      if (ind.fitness > maxFit) {
        maxFit = ind.fitness;
      }
    }
    for (Individual ind : genePool) {
      ind.fitness /= maxFit;
    }
  }
  
  void move() {
    for (Individual ind : genePool) {
      ind.move();
    }
  }
  
  void display() {
    loadPixels();
    for (Individual ind : genePool) {
      ind.display();
    }
    updatePixels();
  }
}

class Individual {
  PVector[] dna;
  
  FloatList minDists;
  
  PVector pos;
  PVector vel;
  PVector acc;
  
  int age = 0;
  
  float fitness;
  
  Individual() {
    dna = new PVector[lifespan];
    for (int i = 0; i < lifespan; i++) {
      dna[i] = PVector.random2D();
    }
    
    pos = new PVector(startingPos.x, startingPos.y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    
    minDists = new FloatList();
    for (int i = 0; i < targets.size(); i++) {
      minDists.push(9999);
    }
  }
  
  Individual(Individual p1, Individual p2) {
    dna = new PVector[lifespan];
    int midpoint = (int)random(lifespan);
    for (int i = 0; i < lifespan; i++) {
      if (random(1) < mutateChance) {
        dna[i] = PVector.random2D();
      }
      else {
        if (i < midpoint) {
          dna[i] = p1.dna[i];
        }
        else {
          dna[i] = p2.dna[i];
        }
      }
    }
    
    pos = new PVector(startingPos.x, startingPos.y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    
    minDists = new FloatList();
    for (int i = 0; i < targets.size(); i++) {
      minDists.push(9999);
    }
  }
  
  void evaluate() {
    float total = 0;
    for (float d : minDists) {
      total += d;
    }
    fitness = 1/(total+0.000001);
  }
  
  void move() {
    acc.add(dna[age]);
    vel.add(acc);
    if (vel.mag() > maxSpeed) {
      vel.setMag(maxSpeed);
    }
    pos.add(vel);
    acc = new PVector(0, 0);
    
    if (bounce) {
      if (pos.x < 0) {
        pos.x = 0;
        vel.x *= -1;
      }
      else if (pos.x > width-1) {
        pos.x = width-1;
        vel.x *= -1;
      }
      if (pos.y < 0) {
        pos.y = 0;
        vel.y *= -1;
      }
      else if (pos.y > height-1) {
        pos.y = height-1;
        vel.y *= -1;
      }
    }
    
    for (int i = 0; i < targets.size(); i++) {
      Target t = targets.get(i);
      float dist = dist(pos.x, pos.y, t.pos.x, t.pos.y);
      if (dist < minDists.get(i)) {
        minDists.set(i, dist);
      }
    }
    
    age++;
  }
  
  void display() {
    int x = (int)pos.x;
    int y = (int)pos.y;
    if (x >= 0 && x < width && y >= 0 && y < height) {
      color c = pixels[x+y*width];
      float b = brightness(c);
      float s = saturation(c);
      if (b > 0 && s == 0) {
        b -= digAmount;
        b = max(0, b);
        pixels[x+y*width] = color(0, 0, b);
      }
      else if (digTwice && (b == 0 || s > 0)) {
        b += reDigAmount;
        b = min(255, b);
        pixels[x+y*width] = color(0, 255, b);
      }
    }
  }
}

void createUI() {
  cp5 = new ControlP5(this);
  
  cp5.addButton("startButton")
    .setPosition(30, 20)
    .setSize(40, 40)
    .setCaptionLabel("START");
  cp5.addSlider("popSize")
    .setPosition(30, 80)
    .setRange(10, 200)
    .setNumberOfTickMarks(191)
    .showTickMarks(false)
    .setValue(100);
  cp5.addSlider("lifespan")
    .setPosition(30, 100)
    .setRange(50, 2000)
    .setNumberOfTickMarks(196)
    .showTickMarks(false)
    .setValue(700);
  cp5.addSlider("mutateChance")
    .setPosition(30, 120)
    .setRange(0.001, 0.05)
    .setValue(0.01);
  cp5.addSlider("maxSpeed")
    .setPosition(30, 140)
    .setRange(1, 10)
    .setValue(4);
  cp5.addSlider("digAmount")
    .setPosition(30, 160)
    .setRange(1, 20)
    .setNumberOfTickMarks(20)
    .showTickMarks(false)
    .setValue(6);
  cp5.addSlider("brightenAmt")
    .setPosition(30, 180)
    .setRange(0, 15)
    .setNumberOfTickMarks(16)
    .showTickMarks(false)
    .setValue(1);
  cp5.addToggle("digTwice")
    .setPosition(30, 210)
    .setValue(false);
  cp5.addSlider("reDigAmount")
    .setPosition(30, 250)
    .setRange(1, 20)
    .setNumberOfTickMarks(20)
    .showTickMarks(false)
    .setValue(1);
  cp5.addToggle("bounce")
    .setPosition(30, 290)
    .setValue(true);
}

void updateValues() {
  popSize = (int)cp5.getController("popSize").getValue();
  lifespan = (int)cp5.getController("lifespan").getValue();
  mutateChance = cp5.getController("mutateChance").getValue();
  maxSpeed = cp5.getController("maxSpeed").getValue();
  digAmount = (int)cp5.getController("digAmount").getValue();
  brightenAmt = (int)cp5.getController("brightenAmt").getValue();
  digTwice = (cp5.getController("digTwice").getValue() == 1.0);
  reDigAmount = (int)cp5.getController("reDigAmount").getValue();
  bounce = (cp5.getController("bounce").getValue() == 1.0);
}

void hideUI() {
  cp5.getController("startButton").hide();
  cp5.getController("popSize").hide();
  cp5.getController("lifespan").hide();
  cp5.getController("mutateChance").hide();
  cp5.getController("maxSpeed").hide();
  cp5.getController("digAmount").hide();
  cp5.getController("brightenAmt").hide();
  cp5.getController("digTwice").hide();
  cp5.getController("reDigAmount").hide();
  cp5.getController("bounce").hide();
}

void mousePressed() {
  if (!started) {
    if (mouseButton == LEFT) {
      for (Target t : targets) {
        if (dist(mouseX, mouseY, t.pos.x, t.pos.y) < targetSize) {
          t.dragging = true;
          return;
        }
      }
      if (dist(mouseX, mouseY, startingPos.x, startingPos.y) < targetSize) {
        draggingStart = true;
      }
    }
    else if (mouseButton == RIGHT) {
      for (int i = 0; i < targets.size(); i++) {
        Target t = targets.get(i);
        if (dist(mouseX, mouseY, t.pos.x, t.pos.y) < targetSize) {
          targets.remove(i);
          break;
        }
      }
    }
  }
}

void mouseReleased() {
  if (!started && !cp5.isMouseOver()) {
    if (mouseButton == LEFT) {
      boolean released = false;
      for (Target t : targets) {
        if (t.dragging) {
          t.dragging = false;
          released = true;
          break;
        }
      }
      if (draggingStart) {
        draggingStart = false;
        released = true;
      }
      if (!released) {
        targets.add(new Target(mouseX, mouseY));
      }
    }
  }
}

void mouseClicked() {
  if (started) {
    String name = "Genetic_Path_" + (int)random(9999) + ".png";
    save(name);
    println("SAVED as " + name);
  }
}
