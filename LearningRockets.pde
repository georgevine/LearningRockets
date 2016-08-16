Rocket[] rockets; //array containing all rocket objects
int lifeCounter; //keeps track of life-length of current generation of rockets (incremented every draw loop)
int genCounter;
int lifeLength; //maximum draws of each rocket before expiration
int numRockets; //number of rockets to spawn each generation

//called immediately on run
void setup() {
  lifeCounter = 0;
  lifeLength = 360;
  genCounter = 1;
  size(1000, 700); //create window with height and width
  numRockets = 75;
  rockets = new Rocket[numRockets]; 
  for(int i = 0; i < numRockets; i++){ //spawn first generation of rockets
    rockets[i] = new Rocket(width/2, height - 100, null);
  }
}


//called continuously throughout program run
void draw(){
  background(0); //clear screen
  if(lifeCounter > lifeLength){ //if the existing generation has expired, create a new generation
    newGen(getGenePool());
  } //update and draw all rockets
  for(int i = 0; i < numRockets; i++){
    rockets[i].draw();
  }
  //set color for drawing target
  stroke(134, 252, 58);
  fill(134, 252, 58);
  //draw target
  ellipse(width / 2, 80, 100, 100);
  //set color for drawing obstacle
  stroke(200, 80, 197);
  fill(200, 80, 197);
  //draw obstacle
  rect(width / 5, height / 2, 3 * width / 5 , 40);
  //increment counter
  lifeCounter++;
  //calcutale maximum fitness of this generation and display it
  float max = maxFitness();
  fill(255, 255, 255);
  textSize(18);
  text("max fitness: " + max, 20, height - 80);
  //calculate average fitness of this generation and display it
  float avg = avgFitness();
  fill(255, 255, 255);
  textSize(18);
  text("average fitness: " + avg, 20, height - 40);
  fill(255, 255, 255);
  textSize(18);
  text("Generation: " + genCounter, width - 160, height - 40);
}


//generate a list of rockets, with each of the rockets in the previous generation being added to the list
//0 to many times based on their fitness values. (higher fintess = more enteries into this list
ArrayList<Rocket> getGenePool(){
  ArrayList<Rocket> genePool = new ArrayList<Rocket>();

  for(int i = 0; i < rockets.length; i++){
    for(int j = 0; j < (int)(rockets[i].returnFitness()); j++){
      genePool.add(rockets[i]);
    }
  }
  return genePool;
}



//Update rockets array by "breeding" new rockets that have a combination of two parent rockets' sequences.
//Parents are randomly selected from the genepool, so that higher fitness rockets are more likely to create offspring.
//After two parents are selected, an arbitrary random split point is generated. The child rocket's sequence will consist of ParentA's sequence
//up to this splitpoint, and Parent B's sequence after this splitpoint, with the exception that every gene in the sequence has a certain chance of 'mutating',
//or being replaced by a new random vector
void newGen(ArrayList<Rocket> genePool){
  genCounter ++;
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
  lifeCounter  = 0;
}




//calculate the maximum fitness of the current generation
float maxFitness(){
  float large = 0;
  for(int i = 0; i < rockets.length; i++){
    if(rockets[i].returnFitness() > large){
      large = rockets[i].returnFitness();
    }
  }
  return large;
}
  
  
//calculate the average fitness of the current generation
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
  PVector[] sequence; //sequence of randomly generated, or parentally generated, acceleration vectors that will be applied to the rocket every draw loop
  float fitness; //metric identifying the rocket's level of success, and therefore its likehood of creating offspring
  public boolean alive; //true if the rocket is currently lving and requires state updates
  
  Rocket(float posx, float posy, PVector[] sequence){
    this.posx = posx;
    this.posy = posy;
    vel = new PVector();
    acc = new PVector();
    fitness = 0;
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
  
  //update rocket state, check for collisions with obstacles, screen boundries, and target, update the rocket's vertex coords, then redraw
  void draw(){
    float td = dist(posx, posy, width/2, 80); //calculate distance to target
    if((posx > width / 5 && posx < (width / 5) + (3 * width / 5)) && (posy > height / 2 && posy < (height / 2) + 40 )){ //check to see if rocket has colided with obstacle
      alive = false;
      td += 50;
    }
    if(td < 60){ //check to see if the rocket has collided with the target
        alive = false;
        fitness = 100;
    }
    if(posx < 0 || posx > width || posy < 0 || posy > height){ //check to see if rocket has left screen
      alive = false;
      td += 50;
    }
    if(lifeCounter >= lifeLength - 1){ //check to see if the rocket has ellapsed its entire lifespan
        alive = false;
    }
    if(!alive){ //if the rocket is no longer living, calculate a fitness metric
        fitness = 1000 / td;
    }
    if(alive){ //if the rocket is living, update in and draw
      posx += vel.x; 
      posy += vel.y;
      acc = sequence[lifeCounter]; //update acceleration
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
      //cacluate coords based on rocket position
      points[0][0] = posx; 
      points[0][1] = posy - 5;
      points[1][0] = posx + 4;
      points[1][1] = posy + 5;
      points[2][0] = posx - 4;
      points[2][1] = posy + 5;
      
      //rotate the coords to show the rocket turning towards its velocity vector
      if(lifeCounter > 0 && lifeCounter < lifeLength - 1 ){
        float theta = angle(new PVector(0, -1), vel);
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
  
  //draw lines between the vertex points
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
  
  //calculate the angle between two vectors, returns value between 0 and 2pi
  public float angle(PVector v1, PVector v2) {
    float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
    if (a < 0) a += TWO_PI;
    return a;
  }
} 