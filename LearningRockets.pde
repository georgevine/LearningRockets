Rocket[] rockets;
int counter;
int lifeLength;
int numRockets;

void setup() {
  counter = 0;
  lifeLength = 325;
  size(1000, 700);
  numRockets = 75;
  rockets = new Rocket[numRockets];
  for(int i = 0; i < numRockets; i++){
    rockets[i] = new Rocket(width/2, height - 100, null);
  }
  stroke(0);
  textSize(18);
  text("max fitness: ", 20, height - 80);
}


void draw(){
  background(0);
  if(counter > lifeLength){
    newGen(getGenePool());
  }
  for(int i = 0; i < numRockets; i++){
    rockets[i].draw();
  }
  stroke(134, 252, 58);
  fill(134, 252, 58);
  ellipse(width / 2, 80, 100, 100);
  stroke(200, 80, 197);
  fill(200, 80, 197);
  rect(width / 5, height / 2, 500, 40);
  counter++;
  float max = maxFitness();
  fill(255, 255, 255);
  textSize(18);
  text("max fitness: " + max, 20, height - 80);
  float avg = avgFitness();
  fill(255, 255, 255);
  textSize(18);
  text("average fitness: " + avg, 20, height - 40);
}


//generate a list of rockets, with each of the rockets in the previous generation being added to the list
//0 to 100 times based on their fitness values
ArrayList<Rocket> getGenePool(){
  ArrayList<Rocket> genePool = new ArrayList<Rocket>();
  
  System.out.println("rocekts length: " + rockets.length);
  for(int i = 0; i < rockets.length; i++){
    System.out.println("fit: " + (int)(rockets[i].returnFitness()));
    for(int j = 0; j < (int)(rockets[i].returnFitness()); j++){
      genePool.add(rockets[i]);
    }
  }
  System.out.println("gene pool size: " + genePool.size());
  return genePool;
}



//update rockets array by "breeding" new rockets that have a combination of two parent rockets' sequences
//parents are randomly selected from the genepool
void newGen(ArrayList<Rocket> genePool){
  for(int i = 0; i < rockets.length; i++){
    Rocket parentA = genePool.get((int)(random(genePool.size())));
    Rocket parentB = genePool.get((int)(random(genePool.size())));
    PVector[] parentASeq = parentA.returnSequence();
    PVector[] parentBSeq = parentB.returnSequence();
    int sequenceSplit = (int)(random(parentASeq.length));
    PVector[] childSequence = new PVector[parentASeq.length];
    for(int j = 0; j < childSequence.length; j++){
      int m = int(random(100));
      if(j < sequenceSplit){
        if(m == 1){
          childSequence[j] = PVector.random2D().mult(random(-.3, .3));
        } else {
          childSequence[j] = parentASeq[j];
        }
      } else {
        if(m == 1){
          childSequence[j] = PVector.random2D().mult(random(-.3, .3));
        } else {
          childSequence[j] = parentBSeq[j];
        }
      }
    }
    Rocket childRocket = new Rocket(width / 2, height - 200, childSequence);
    rockets[i] = childRocket;
  }
  counter  = 0;
}





float maxFitness(){
  float large = 0;
  for(int i = 0; i < rockets.length; i++){
    if(rockets[i].returnFitness() > large){
      large = rockets[i].returnFitness();
    }
  }
  return large;
}
  
  
float avgFitness(){
  float avg = 0;
    for(int i = 0; i < rockets.length; i++){
      avg += rockets[i].returnFitness();
    }
  avg = avg / rockets.length;
  return avg;
}
  
  
//Rocket object
class Rocket{
  float posx, posy; //create floats to hold x and y coords
  PVector vel, acc; //create vectors to track velocity, and acceleration
  float[][] points; //create float arrays to track rocket body vertecesfor drawing
  PVector[] sequence; 
  float fitness; 
  public boolean alive;
  
  Rocket(float posx, float posy, PVector[] sequence){
    this.posx = posx;
    this.posy = posy;
    vel = new PVector();
    acc = new PVector();
    fitness = 1000;
    points = new float[3][2];
    alive = true;
    updatePoints();
    if(sequence != null){
      this.sequence = sequence;
    } else {
      this.sequence = new PVector[lifeLength];
      for(int i = 0; i < lifeLength; i++){
        this.sequence[i] = PVector.random2D().mult(random(-.3, .3));
      }
    }
  }
  
  void draw(){
    float td = dist(posx, posy, width/2, 80); //calculate distance to target
    if((posx > width / 5 && posx < (width / 5) + 500) && (posy > height / 2 && posy < (height / 2) + 40 )){ //check to see if rocket has colided with obstacle
      alive = false;
      td += 50;
    }
    if(td < 60){ //check to see if the rocket has collided with the target
        alive = false;
        fitness = 100;
    }
    if(posx < 0 || posx > width || posy < 0 || posy > height){
      alive = false;
      td += 50;
    }
    if(counter >= lifeLength - 1){ //check to see if the rocket has ellapsed its entire lifespan
        alive = false;
    }
    if(!alive){ //if the rocket is no longer living, calculate a fitness metric
        fitness = 1000 / td;
    }
    if(alive){
      posx += vel.x; 
      posy += vel.y;
      acc = sequence[counter]; //update acceleration
      vel.add(acc); //use acceleration to update velocity
      if(Math.abs(vel.x) > 8 || Math.abs(vel.y) > 8){
        vel.sub(acc);
      } 
      //use velocity to update position
      updatePoints();
      drawRocketShape();
    }
  }
  
  //update vertex positions based on rocket position
  void updatePoints(){
      points[0][0] = posx; 
      points[0][1] = posy - 5;
      points[1][0] = posx + 4;
      points[1][1] = posy + 5;
      points[2][0] = posx - 4;
      points[2][1] = posy + 5;
      
      
      if(counter > 0 && counter < lifeLength - 1 ){
        float theta = angle(new PVector(0, -1), vel);
        System.out.println("theta: " + theta);
        float[][] newPoints = new float[3][2];
        newPoints[0][0] = ((points[0][0] - posx) * cos(theta)) - ((points[0][1] - posy) * sin(theta)) + posx;
        newPoints[0][1] = ((points[0][1] - posy) * cos(theta)) + ((points[0][0] - posx) * sin(theta)) + posy;
        newPoints[1][0] = ((points[1][0] - posx) * cos(theta)) - ((points[1][1] - posy) * sin(theta)) + posx;
        newPoints[1][1] = ((points[1][1] - posy) * cos(theta)) + ((points[1][0] - posx) * sin(theta)) + posy;
        newPoints[2][0] = ((points[2][0] - posx) * cos(theta)) - ((points[2][1] - posy) * sin(theta)) + posx;
        newPoints[2][1] = ((points[2][1] - posy) * cos(theta)) + ((points[2][0] - posx) * sin(theta)) + posy;
        points = newPoints;
      }
  }
  
  void drawRocketShape(){
    stroke(134, 252, 58);
    line(points[0][0], points[0][1], points[1][0], points[1][1]);
    line(points[1][0], points[1][1], points[2][0], points[2][1]);
    line(points[2][0], points[2][1], points[0][0], points[0][1]);
  }
  
  
  public float returnFitness(){
    return fitness; 
  }
  
  public PVector[] returnSequence(){
    return sequence;
  }
  
  public float angle(PVector v1, PVector v2) {
    float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
    if (a < 0) a += TWO_PI;
    return a;
  }
} 