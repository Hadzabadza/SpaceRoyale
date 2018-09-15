  class Star extends Object{
  float mass;

  Star() {
    super(new PVector(),new PVector(),0,0);
    mass=random(100, 1000);
    radius=sqrt(mass)*5;
    diameter=radius*2;
    pos.x=round(random(-width, width));
    pos.y=round(random(-height, height));
    float distS=random(50, 300);
    int isAsteroid=round(random(0,100));
    for (int i=0; i<round(random(Settings.minPlanetsPerStar, Settings.maxPlanetsPerStar)); i++) {
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
    diameter=radius*2;
    float distS=random(500, 1000);
    int isAsteroid=round(random(0,100));
    for (int i=0; i<round(random(Settings.minPlanetsPerStar, Settings.maxPlanetsPerStar)); i++) {
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

  void draw(PGraphics renderer)
  {
    renderer.stroke(0);
    renderer.fill(255, 200, 40);
    renderer.ellipse (pos.x, pos.y, diameter, diameter);
  }
  void spawn(){
    stars.add(this);
    super.spawn();
  }
  void queueDestroy(){
    destroyees.add(this);
  }
  void destroy(){
    stars.remove(this);
    super.destroy();
  }
}