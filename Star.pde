class Star extends Object {
  float mass;
  int gravWellRadius;
  int gravWellDiameter;
  float gravPull;
  color c;
  float surfaceTemp;
  Planet[] planets;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Star() {
    super(new PVector(), new PVector(), 0, 0);
    starInit();
  }

  Star(float x, float y) {
    super(new PVector(x, y), new PVector(), 0, 0);
    starInit();
  }

  void starInit() {
    planets=new Planet[round(random(Settings.minPlanetsPerStar, Settings.maxPlanetsPerStar))];
    mass=random(Settings.minStarMass, Settings.maxStarMass);
    c=recalculateTemp(Settings.minStarTemp*pow(2, mass/Settings.minStarMass-1));
    radius=300+sqrt(mass);
    diameter=radius*2;
    gravPull=mass;
    float distS=random(3000, 6000)+sqrt(surfaceTemp);
    //int isAsteroid=round(random(0, 100));
    for (int i=0; i<planets.length; i++) {
      /*if (isAsteroid>40) {
       float pMass=random(1, 5);
       distS+=random(10, 30)+sqrt(pMass)*5*2;
       for (int asters=0; asters<round(random(Settings.minAsteroidsPerChain, Settings.maxAsteroidsPerChain)); asters++) asteroids.add(new Asteroid(this, pMass, distS));
       }
       isAsteroid=round(random(0, 100));*/
      float pMass=random(10000, 100000);
      if (i>0) distS+=random(1000, 2000)+planets[i-1].gravWellDiameter;
      else distS+=random(1000, 2000);
      planets[i]=new Planet(this, pMass, random(0.5, 0.9), distS, i+1);
    }
    distS+=random(2000, 5000);
    gravWellRadius=round(distS+planets[planets.length-1].gravWellDiameter);
    gravWellDiameter=gravWellRadius*2;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

    color recalculateTemp(float temp) {
    surfaceTemp=temp;
    temp/=100;
    float red;
    float green;
    float blue;
    //Calculate Red:
    if (temp <= 66) red = 255;
    else {
      red = temp - 60;
      red = 329.698727446 * pow(red, -0.1332047592);
      if (red < 0)  red = 0;
      else if (red > 255) red = 255;
    }

    //Calculate Green:
    if (temp <= 66) {
      green = temp;
      green = 99.4708025861 * log(green) - 161.1195681661;
      if (green < 0) green = 0;
      else if (green > 255) green = 255;
    } else { 
      green = temp - 60;
      green = 288.1221695283 * pow(green, -0.0755148492);
      if (green < 0) green = 0;
      else if (green > 255) green = 255;
    }

    //Calculate Blue:
    if (temp >= 66) blue = 255;
    else if (temp <= 19) blue = 0;
    else {
      blue = temp - 10;
      blue = 138.5177312231 * log(blue) - 305.0447927307;
      if (blue < 0) blue = 0;
      if (blue > 255) blue = 255;
    }
    return color(red, green, blue);
  }   

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void update() {
    pullObjects();
    heatObjects();
  }

  void pullObjects() { //Gravitational pull
    float currDist;
    for (Ship s : ships) { 
      if (!s.warp) {
        currDist=getDistTo(s);
        if (currDist<gravWellRadius&&currDist>radius) {
          s.vel.add(new PVector(pos.x-s.pos.x, pos.y-s.pos.y).normalize().mult(gravPull/pow(currDist, 2)));
          //println(gravPull/pow(currDist, 2));
        }
      }
    }
    for (Particle p : particles) { 
      currDist=getDistTo(p);
      if (currDist<radius) p.queueDestroy();
      else if (currDist<gravWellRadius) {
        p.vel.add(new PVector(pos.x-p.pos.x, pos.y-p.pos.y).normalize().mult(gravPull/2/pow(currDist, 2)));
      }
    }
  }

  void heatObjects() { //HOTHOTHOT
    float currDist;
    float heatIntensity;
    boolean inShade;
    for (Ship s : ships) {
      inShade=false;
      for (Planet p : planets) {
        inShade=p.checkIfShaded(s.pos);
        if (inShade) break;
      }
      if (!inShade) {
        currDist=getDistTo(s)-radius;
        if (currDist<s.radius) {
          heatIntensity=mass/(PI*radius*2)*s.radius;
          for (int i=0; i<s.heatArray.length; i++) s.heatArray[i]+=heatIntensity;
        } else if (currDist<gravWellRadius) {
          heatIntensity=mass/(PI*currDist*2)*s.radius;
          s.heatUpSide(s.getDirTo(this), heatIntensity);
        }
      }
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void softDraw(PGraphics rr) {
    rr.pushMatrix();
    rr.translate(0, 0, 1);
    rr.noFill();
    rr.strokeWeight(1);
    float blink=gameTime;
    rr.stroke(c);
    blink=cos(gameTime/4%HALF_PI);
    float blink2=cos((gameTime/4+HALF_PI/3)%HALF_PI);
    float blink3=cos((gameTime/4+HALF_PI/3*2)%HALF_PI);
    rr.ellipse (pos.x, pos.y, gravWellDiameter*(blink), gravWellDiameter*(blink));
    rr.ellipse (pos.x, pos.y, gravWellDiameter*(blink2), gravWellDiameter*(blink2));
    rr.ellipse (pos.x, pos.y, gravWellDiameter*(blink3), gravWellDiameter*(blink3));
    rr.ellipse (pos.x, pos.y, gravWellDiameter, gravWellDiameter);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
    rr.popMatrix();
  }

  void draw(PGraphics rr)
  {
    softDraw(rr);
    rr.stroke(0);
    rr.fill(c);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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
