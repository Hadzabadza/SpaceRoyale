class Star extends Object {
  float mass;
  int gravWellRadius;
  int gravWellDiameter;
  float gravPull;

  Star() {
    super(new PVector(), new PVector(), 0, 0);
    starInit();
  }

  Star(float x, float y) {
    super(new PVector(x, y), new PVector(), 0, 0);
    starInit();
  }

  void starInit() {
    mass=random(300, 800);
    radius=mass;
    diameter=radius*2;
    gravPull=mass/10000;
    gravWellRadius=round(radius*Settings.gravityWellRadiusMultiplier);
    gravWellDiameter=gravWellRadius*2;
    float distS=random(300, 600)+gravWellRadius+mass;
    int isAsteroid=round(random(0, 100));
    for (int i=0; i<round(random(Settings.minPlanetsPerStar, Settings.maxPlanetsPerStar)); i++) {
      if (isAsteroid>40) {
        float pMass=random(1, 5);
        distS+=random(10, 30)+sqrt(pMass)*5*2;
        for (int asters=0; asters<round(random(Settings.minAsteroidsPerChain, Settings.maxAsteroidsPerChain)); asters++) asteroids.add(new Asteroid(this, pMass, distS));
      }
      isAsteroid=round(random(0, 100));
      float pMass=random(10, 100);
      distS+=random(100, 1000)+sqrt(pMass)*5*2;
      planets.add(new Planet(this, pMass, distS, i+1));
    }
  }

  void softDraw(PGraphics rr) {
    rr.pushMatrix();
    rr.translate(0, 0, 1);
    rr.noFill();
    rr.strokeWeight(1);
    float blink=gameTime;
    rr.stroke(150+50*sin(blink), 150+50*sin(blink), 0);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
    blink=cos(blink%HALF_PI);
    rr.ellipse (pos.x, pos.y, gravWellDiameter*(blink), gravWellDiameter*(blink));
    rr.ellipse (pos.x, pos.y, gravWellDiameter, gravWellDiameter);
    rr.popMatrix();
  }

  void update() {
    pullObjects();
  }

  void draw(PGraphics rr)
  {
    softDraw(rr);
    rr.stroke(0);
    rr.fill(255, 200, 40);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
  }

  void pullObjects() { //Gravitational pull
    float currDist;
    for (Ship s : ships) { 
      if (!s.warp) {
        currDist=dist(s.pos.x, s.pos.y, pos.x, pos.y);
        if (currDist<gravWellRadius&&currDist>radius) {
          s.vel.add(new PVector(pos.x-s.pos.x, pos.y-s.pos.y).normalize().mult(gravPull*(1-pow(currDist/gravWellRadius,2))));
        }
      }
    }
    for (Particle p : particles) { 
      currDist=dist(p.pos.x, p.pos.y, pos.x, pos.y);
      if (currDist<gravWellRadius&&currDist>radius) {
        p.vel.add(new PVector(pos.x-p.pos.x, pos.y-p.pos.y).normalize().mult(gravPull*(1-currDist/gravWellRadius)));
      }
    }
  }

  void spawn() {
    stars.add(this);
    super.spawn();
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    stars.remove(this);
    super.destroy();
  }
}
