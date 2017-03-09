int entities = 1200;
int length = 80; // length of DNA sequence.
float energyConsumption = 0.82;
float directionChangeInterval = 5; //higher = changes less frequent
float lowerBoundEnergy = 350;
float higherBoundEnergy = 350;
Entity[] a = new Entity[entities];
DNA[] dna = new DNA[a.length];
Target t = new Target(0,0);
int generation = 1;
float mutationRate = 0.01;
boolean resetted = false;
ArrayList<DNA> bestDNA = new ArrayList<DNA>();
int learningSpeed = 2; //don't go over 12
boolean reachedTarget = false;


void setup() {
  size(900, 600);
  for (int i = 0;i<a.length;i++) {
    dna[i] = new DNA();
    a[i] = new Entity(20,dna[i].energy);
    a[i].spawn();
    t.x=width-110;
    t.y=height/2;
    
  }
}


void draw() {
  if (reachedTarget) {
    background(0,255,0);
    fill(0,0,0);
    textSize(29);
    String n = "Destination Reached in Generation " + generation;
    text(n, 40, height/2);
    textSize(18);
    String t = "Try Again?";
    text(t, 40, (height/2)+30);
    
  }
  if (!reachedTarget) {
  background(0,0,0);
  fill(255,255,255);
  textSize(32);
  String n = "GENERATION: " + generation;
  text(n, 600, 50);
  textSize(19);
  String ab = "Average Distance " + averageDistanceFromTarget();
  text(ab, 600, 100);
  String abc = "Closest Distance " + closestDistanceFromTarget();
  text(abc, 600, 130);
  String mut = "Mutation Rate: " + mutationRate;
  text(mut, 600, 160);
  String ler = "Learning Speed (1-12): " + learningSpeed;
  text(ler, 600, 190);
  fill(255,0,0);
  rect(averageXValue(),0,15,height);
  textSize(14);
  String val = "Average Distance travelled, Generation " + generation;
  text(val, averageXValue()+20, 550);
  
  if (generationInProgress()) {
    for (int i = 0;i<a.length;i++) {
      a[i].nav(dna[i].genes);
    }
  }
  if (!generationInProgress()) {
    
    if (!resetted) {
    generation++;
    resetted = true;
    if (closestDistanceFromTarget()<0) {
        reachedTarget = true;
      }
    }
    if (resetted) {
      resetted = false;
      for (int i = 0;i<a.length;i++) {
        a[i].energy = dna[i].energy;
        dna[i].calculateFitness(a[i],dna[i]);
        newMatingPool();
        dna[i] = newGeneration(int(random(35)));
        a[i].spawn();
        a[i].reset();
      }
    }
  }

  t.spawn();
  }
}

float averageDistanceFromTarget() {
  float cumulativeDistance = 0;
  for (int i = 0; i<a.length;i++) {
    cumulativeDistance += dist(a[i].x,a[i].y,t.x,t.y);
  }
  float average  = cumulativeDistance/a.length;
  return average-50;
}

float averageXValue() {
  float cumulativeX = 0;
  for (int i = 0; i<a.length;i++) {
    cumulativeX += a[i].x;
  }
  float average  = cumulativeX/a.length;
  return average;
}

float closestDistanceFromTarget() {
  float closest =  dist(a[0].x,a[0].y,t.x,t.y);
  for (int i = 1; i<a.length;i++) {
    float distOfEntity =  dist(a[i].x,a[i].y,t.x,t.y);
    if (distOfEntity<closest) {
      closest = distOfEntity;
    }
  }
  return closest-50;
}

boolean generationInProgress() {
  for (int i = 0; i < a.length;i++) {
    if (a[i].energy > 0) {
      return true;
    }
  }
  return false;
}

void newMatingPool() {
  bestDNA.clear();
  float maxFitness = 0;
  for (int i = 0; i < dna.length; i++) {
      dna[i].calculateFitness(a[i],dna[i]);
      if (dna[i].fitness > maxFitness) {
        maxFitness = dna[i].fitness;
      }
  }
  for (int i = 0; i < dna.length; i++) {
      
      float fitness = map(dna[i].fitness,0,maxFitness,0,1);
      int n = int(fitness * 200);
      for (int j = 0; j < n; j++) {    
          bestDNA.add(dna[i]);
      }
    }
}

class DNA {

  float[] genes = new float[length];
  float fitness = 0;
  float energy = 0;
  
  DNA() {
    energy = random(lowerBoundEnergy,higherBoundEnergy);
    genes[0] = random(-150,150);
    for (int i = 1;i<genes.length;i++) {
      genes[i] = random(genes[i-1]-50,genes[i-1]+50);
    }
  }
  
  void calculateFitness(Entity a, DNA d) {
    fitness = 0;
    float distanceFromTarget = dist(a.x,a.y,t.x,t.y);
    for (int i = 0;i<length;i++) {
      if (d.genes[i]>70 && d.genes[i]<290) {
        fitness -= 100;
      }
      if (d.genes[i]>-290 && d.genes[i]<-70) {
        fitness -= 100;
      }
    }
    for (int j = 1;j<length;j++) {
      if (abs(d.genes[j]-d.genes[j-1])>50) {
        fitness -= 75;
      }
    }
    if (distanceFromTarget<1000) {
      fitness = 1000-distanceFromTarget;
      if (distanceFromTarget<225) {
        fitness += 300;
      }
      if (distanceFromTarget<150) {
        fitness += 750;
      }
      if (distanceFromTarget<100) {
        fitness += 1200;
      }
      if (distanceFromTarget<75) {
        fitness += 1750;
      }
      if (distanceFromTarget<60) {
        fitness += 2000;
      }
      if (distanceFromTarget<50) {
        fitness += 2500;
      }
      if (distanceFromTarget<45) {
        fitness*=(45-distanceFromTarget);
      }
      if (a.y>100&&a.y<500) {
        fitness += 100;
        if (a.y>150 && a.y<450) {
          fitness += 55;
          if (a.y>200 && a.y<400) {
            fitness += 35;
            if (a.y>250 && a.y<350) {
                fitness += 22.5;
               }
          }
        }
      } 
      if (a.y<100) {
      fitness = 5;
    }
    if (a.y>350) {
      fitness = 5;
    }
    }
    else {
      fitness = 0.1;
    }
    fitness /= 1000;
    fitness = pow(fitness,learningSpeed);
  }
  
  DNA crossover(DNA partner, int midpoint) {
    // A new child
    DNA child = new DNA();
    
    // Half from one, half from the other
    for (int i = 0; i < genes.length; i++) {
      if (i > midpoint) child.genes[i] = (genes[i])+random(-10,10);
      else              child.genes[i] = partner.genes[i] + random(-10,10);
    }
    return child;
  }
  
  DNA mutate(DNA original) {
    DNA child = original;
    float random = random(1);
    if (random<mutationRate) {
      int randomIndex = int(random(length));
      child.genes[randomIndex] = random(-30,30);
      randomIndex = int(random(length));
      child.genes[randomIndex] = random(-30,30);
      randomIndex = int(random(length));
      child.genes[randomIndex] = random(-30,30);
    }
    return child;
  }
  
}

DNA newGeneration(int x) {
    int indexOne = int(random(bestDNA.size()));
    int indexTwo = int(random(bestDNA.size()));
    DNA partnerA = bestDNA.get(indexOne);
    DNA partnerB = bestDNA.get(indexTwo);
    DNA child = partnerA.crossover(partnerB, x);
    child = child.mutate(child);
    return child;
}

class Entity {

 float x,y,stepX,stepY,diam;
 boolean done = false;
 float energy;
 float highEnergy = energy;
 float initialAngle = 0;
 float multiplierX = 1;
 float multiplierY = 1;
 int moves = 0;
 int runs = 0;
 
 Entity (float d, float e) { //magnitude of the movement, diameter of the shape
   diam = d;
   energy = e;
 }
  void reset() {
    moves = 0;
    runs = 0;
  }
  void spawn() {
    fill(255,255,255);
    x=50;
    y= height/2;
    ellipse(x,y, diam, diam);
  }
  void nav(float[] genes) {
    initialAngle = genes[moves]*PI/180;
    if (moves<(length-1) && runs%directionChangeInterval == 0) {
      moves++;
    }
    else {
      initialAngle-=2*PI/180;
    }
    runs++;
    x=x+((energy/100)*cos(initialAngle)*multiplierX);
    y=y-((energy/100)*sin(initialAngle)*multiplierY);
    if(energy>0) {
      energy -= energyConsumption;
      }
    if (energy<0) {
      energy = 0;
    }
    fill(255,255,255);
    ellipse(x,y, diam, diam);
    if (x>(width-(diam/2)) || x<(0+(diam/2)) ) {
      multiplierX = -multiplierX;
    }
    if (y>(height-(diam/2)) || y<(0+(diam/2)) ) {
      multiplierY = -multiplierY;
    }
  }
}

class Target {

  int x,y;
  
  Target(int a,int b) {
  x=a;
  y=b;
  }
  void spawn() {
    fill(255,0,0);
    ellipse(x,y, 80,80);
    String ler = "TZUYU";
    text(ler, x-20, y+70);
  }

}
