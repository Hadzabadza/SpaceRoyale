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
    vel.x=sqrt(0.0001*distance)*cos(phase+HALF_PI);
    vel.y=sqrt(0.0001*distance)*sin(phase+HALF_PI);
    pos.x=orbitStar.pos.x+distance*cos(phase);
    pos.y=orbitStar.pos.y+distance*sin(phase);
  }

  void draw(PGraphics rr) 
  {
    rr.pushMatrix();
    rr.translate(0, 0, -1);
    rr.stroke(255, 105+55*cos(radians(frameCount)),105+55*cos(radians(frameCount)),125+75*cos(radians(frameCount)));
    rr.noFill();
    rr.ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    rr.line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    rr.popMatrix();

    rr.pushMatrix();
    rr.translate(0, 0, 1);
    rr.fill(200,20,100);
    rr.strokeWeight(3);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
    rr.strokeWeight(1);
    rr.noFill();
    rr.ellipse (pos.x,pos.y,diameter*10,diameter*10);
    rr.popMatrix();
  }

  void update() {
    grav=new PVector();
    grav.x=-(pos.x-orbitStar.pos.x);
    grav.y=-(pos.y-orbitStar.pos.y);
    grav.normalize();
    grav.mult(0.0001);
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