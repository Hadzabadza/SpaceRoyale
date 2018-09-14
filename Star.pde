  class Star extends Object{
  float mass;

  Star() {
    super(new PVector(),new PVector(),0,0);
    mass=random(100, 1000);
    radius=sqrt(mass)*5;
    pos.x=round(random(-width, width));
    pos.y=round(random(-height, height));
    float distS=random(50, 300);
    int isAsteroid=round(random(0,100));
    for (int i=0; i<round(random(minPlanetsPerStar, maxPlanetsPerStar)); i++) {
      if (isAsteroid>40){
        float pMass=random(1, 5);
        distS+=random(10, 100)+sqrt(pMass)*5*2;
        asteroids.add(new Asteroid(this, pMass, distS));
        distS+=random(10, 100)+sqrt(pMass)*5*2;
      }
      isAsteroid=round(random(0,100));
      float pMass=random(10, 100);
      distS+=random(40, 100)+sqrt(pMass)*5*2;
      planets.add(new Planet(this, pMass, distS, i+1));
    }
  }

  Star(float x, float y) {
    super(new PVector(x,y),new PVector(),0,0);
    mass=random(100, 1000);
    radius=sqrt(mass)*5;
    float distS=random(500, 1000);
    int isAsteroid=round(random(0,100));
    for (int i=0; i<round(random(minPlanetsPerStar, maxPlanetsPerStar)); i++) {
      if (isAsteroid>40){
        float pMass=random(1, 5);
        distS+=random(10, 30)+sqrt(pMass)*5*2;
        asteroids.add(new Asteroid(this, pMass, distS));
      }
      isAsteroid=round(random(0,100));
      float pMass=random(10, 100);
      distS+=random(100, 1000)+sqrt(pMass)*5*2;
      planets.add(new Planet(this, pMass, distS, i+1));
    }
  }

  void draw()
  {
    stroke(0);
    fill(255, 200, 40);
    ellipse (pos.x, pos.y, radius*2, radius*2);
  }
  void destroy(){
    stars.remove(this);
    super.destroy();
  }
}