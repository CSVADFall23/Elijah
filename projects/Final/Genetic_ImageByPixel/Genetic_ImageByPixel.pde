String fileName = "MATLogo";
String fileType = "png";
PImage img;
PImage resultImg;

Population population;
int round = 0;

int populationSize = 100;
float mutationChance = 0.04;
float mutationAmt = 128;
int tournamentNum = 10;
int resolution = 256;
boolean save = false;

void settings() {
  img = loadImage(fileName + "." + fileType);
  img.resize(resolution, resolution);
  size(img.width*3, img.height);
}

void setup() {
  colorMode(RGB, 255);
  background(0);
  
  image(img, 2*img.width, 0);
  resultImg = new PImage(img.width, img.height);
  
  population = new Population();
  DNA best = population.bestChoice();
  best.display(0, 0);
  //for (int i = 0; i < 4; i++) {
  //  int index = (int)random(populationSize);
  //  DNA dna = population.genePool.get(index);
  //  dna.display(int(i/4.0*width), height/2);
  //}
  image(differenceImage(best, img), img.width, 0);
  if (save) {
    save("fileName" + "_GeneticPixels_" +round+".png");
  }
}

void draw () {
  population.naturalSelection();
  DNA best = population.bestChoice();
  best.display(0, 0);
  image(differenceImage(best, img), img.width, 0);
  round++;
  println(best.fitness + "    " + round);
  if (save && (round == 2 || round == 10 || round == 30)) {
    save("fileName" + "_GeneticPixels_" +round+".png");
  }
}

PImage differenceImage(DNA best, PImage img) {
  PImage newImg = new PImage(img.width, img.height);
  img.loadPixels();
  color[] cArray1 = best.genes;
  color[] cArray2 = img.pixels;
  newImg.loadPixels();
  for (int i = 0; i < newImg.pixels.length; i++) {
    int redDif = (int)abs(red(cArray1[i]) - red(cArray2[i]));
    int greenDif = (int)abs(green(cArray1[i]) - green(cArray2[i]));
    int blueDif = (int)abs(blue(cArray1[i]) - blue(cArray2[i]));
    int totalDif = (redDif+greenDif+blueDif)/3;
    newImg.pixels[i] = color(totalDif);
  }
  newImg.updatePixels();
  return newImg;
}

class Population {
  ArrayList<DNA> genePool;
  
  Population() {
    genePool = new ArrayList<DNA>();
    for (int i = 0; i < populationSize; i++) {
      genePool.add(new DNA());
    }
  }
  
  void naturalSelection() {
    ArrayList<DNA> newGenePool = new ArrayList<DNA>();
    for (int i = 0; i < populationSize; i++) {
      DNA p1 = tournamentSelect();
      DNA p2 = tournamentSelect();
      newGenePool.add(new DNA(p1, p2));
    }
    genePool = newGenePool;
  }
  
  DNA weightedChoice() {
    while(true) {
      int index = (int)random(genePool.size());
      DNA option = genePool.get(index);
      if (random(1) < option.fitness) {
        return option;
      }
    }
  }
  
  DNA tournamentSelect() {
    DNA best = genePool.get((int)random(genePool.size()));
    for (int i = 0; i < tournamentNum-1; i++) {
      DNA compare = genePool.get((int)random(genePool.size()));
      if (compare.fitness > best.fitness) {
        best = compare;
      }
    }
    return best;
  }
  
  DNA bestChoice() {
    DNA best = genePool.get(0);
    for (int i = 1; i < genePool.size(); i++) {
      DNA compare = genePool.get(i);
      if (compare.fitness > best.fitness) {
        best = compare;
      }
    }
    return best;
  }
  
  float averageFitness() {
    float total = 0;
    for (DNA dna : genePool) {
      total += dna.fitness;
    }
    total /= genePool.size();
    return total;
  }
}

class DNA {
  color[] genes;
  FloatList fitnesses;
  float fitness;
  
  DNA() {
    genes = new int[img.width*img.height];
    for (int i = 0; i < genes.length; i++) {
      genes[i] = color((int)random(255), (int)random(255), (int)random(255));
    }
    setFitness();
  }
  
  DNA(DNA p1, DNA p2) {
    genes = new int[img.width*img.height];
    for (int i = 0; i < genes.length; i++) {
      float f1 = p1.fitnesses.get(i);
      float f2 = p2.fitnesses.get(i);
      if (random(f1+f2) < f1) {
        genes[i] = p1.genes[i];
      }
      else {
        genes[i] = p2.genes[i];
      }
    }
    for (int i = 0; i < genes.length; i++) {
      color c = genes[i];
      int r = (int)red(c);
      int g = (int)green(c);
      int b = (int)blue(c);
      if (random(1) < mutationChance) {
        r += (int)random(-mutationAmt, mutationAmt);
        r = constrain(r, 0, 255);
      }
      if (random(1) < mutationChance) {
        g += (int)random(-mutationAmt, mutationAmt);
        g = constrain(g, 0, 255);
      }
      if (random(1) < mutationChance) {
        b += (int)random(-mutationAmt, mutationAmt);
        b = constrain(b, 0, 255);
      }
      genes[i] = color(r, g, b);
    }
    setFitness();
  }
  
  void setFitness() {
    fitnesses = new FloatList();
    img.loadPixels();
    float total = 0;
    for (int i = 0; i < genes.length; i++) {
      float f = geneFitness(genes[i], img.pixels[i]);
      fitnesses.push(f);
      total += f;
    }
    total /= genes.length;
    fitness = total;
  }
  
  void display(int x, int y) {
    resultImg.loadPixels();
    for (int i = 0; i < genes.length; i++) {
      resultImg.pixels[i] = genes[i];
    }
    resultImg.updatePixels();
    image(resultImg, x, y);
  }
}

float geneFitness(int c1, int c2) {
  float fit = 1/(deltaE(c1, c2)*0.1+1);
  return fit;
}

float deltaE(int c1, int c2) {
  float[] RGB1 = {red(c1), green(c1), blue(c1)};
  float[] RGB2 = {red(c2), green(c2), blue(c2)};
  float[] CIE1 = XYZtoCIE(RGBtoXYZ(RGB1));
  float[] CIE2 = XYZtoCIE(RGBtoXYZ(RGB2));
  
  float deltaE = sqrt(pow((CIE1[0]-CIE2[0]),2)+pow((CIE1[1]-CIE2[1]),2)+pow((CIE1[2]-CIE2[2]),2));
  deltaE = min(deltaE, 100);
  return deltaE;
}

float[] RGBtoXYZ(float[] starting) {
  float r = starting[0]/255.0;
  float g = starting[1]/255.0;
  float b = starting[2]/255.0;
  
  if (r > 0.04045) {
    r = pow(((r+0.055)/1.055), 2.4);
  } else {
    r /= 12.92;
  }
  if (g > 0.04045) {
    g = pow(((g+0.055)/1.055), 2.4);
  } else {
    g /= 12.92;
  }
  if (b > 0.04045) {
    b = pow(((b+0.055)/1.055), 2.4);
  } else {
    b /= 12.92;
  }
  
  r *= 100;
  g *= 100;
  b *= 100;
  
  float x = r*0.4124 + g*0.3576 + b*0.1805;
  float y = r*0.2126 + g*0.7152 + b*0.0722;
  float z = r*0.0193 + g*0.1192 + b*0.9505;
  float[] newColor = {x, y, z};
  return newColor;
}

float[] XYZtoCIE(float[] starting) {
  float x = starting[0]/100.0;
  float y = starting[1]/100.0;
  float z = starting[2]/100.0;
  
  if (x > 0.008856) {
    x = pow(x, (1/3.0));
  } else {
    x = x*7.787 + 16/116.0;
  }
  if (y > 0.008856) {
    y = pow(y, (1/3.0));
  } else {
    y = y*7.787 + 16/116.0;
  }
  if (z > 0.008856) {
    z = pow(z, (1/3.0));
  } else {
    z = z*7.787 + 16/116.0;
  }
  
  float L = 116*y - 16;
  float a = 500*(x-y);
  float b = 200*(y-z);
  float[] newColor = {L, a, b};
  return newColor;
}
