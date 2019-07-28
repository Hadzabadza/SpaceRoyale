class Asteroid extends Object{
  float mass;
  float distance;
  PVector grav;
  Star orbitStar;

  Asteroid (Star s, float mas, float distS) {
    super(new PVector(), new PVector(),0,sqrt(mas)*5);
    orbitStar=s;
    mass=mas;
    distance = distS+orbitStar.radius;
    float phase=random(0, TWO_PI);
    vel.x=sqrt(Settings.celestialPull*distance)*cos(phase+HALF_PI);
    vel.y=sqrt(Settings.celestialPull*distance)*sin(phase+HALF_PI);
    pos.x=orbitStar.pos.x+distance*cos(phase);
    pos.y=orbitStar.pos.y+distance*sin(phase);
  }

  void softDraw(PGraphics rr){
    rr.pushMatrix();
    rr.translate(0, 0, -1);
    rr.stroke(145, 75+35*cos(gameTime),75+35*cos(gameTime),105+35*cos(gameTime));
    rr.noFill();
    rr.ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    //rr.line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    rr.popMatrix();
  }

  void draw(PGraphics rr) 
  {
    softDraw(rr);
    rr.pushMatrix();
    rr.translate(0, 0, 1);
    rr.fill(200,20,100);
    rr.strokeWeight(1);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
    rr.popMatrix();
  }

  void update() {
    grav=new PVector();
    grav.x=-(pos.x-orbitStar.pos.x);
    grav.y=-(pos.y-orbitStar.pos.y);
    grav.normalize();
    grav.mult(Settings.celestialPull);
    vel.add(grav);
    super.update();
  }
  void spawn(){
    asteroids.add(this);
    super.spawn();
  }
  void queueDestroy(){
    destroyees.add(this);
  }
  void destroy(){
    asteroids.remove(this);
    super.destroy();
  }
}
