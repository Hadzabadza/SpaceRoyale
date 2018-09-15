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
    float phase=random(0, 360);
    vel.x=sqrt(0.0001*distance)*cos(radians(phase+90));
    vel.y=sqrt(0.0001*distance)*sin(radians(phase+90));
    pos.x=orbitStar.pos.x+distance*cos(radians(phase));
    pos.y=orbitStar.pos.y+distance*sin(radians(phase));
  }

  void draw(PGraphics renderer) 
  {
    renderer.pushMatrix();
    renderer.translate(0, 0, -1);
    renderer.stroke(255, 105+55*cos(radians(frameCount)),105+55*cos(radians(frameCount)),125+75*cos(radians(frameCount)));
    renderer.noFill();
    renderer.ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    renderer.line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    renderer.popMatrix();

    renderer.pushMatrix();
    renderer.translate(0, 0, 1);
    renderer.fill(200,20,100);
    renderer.strokeWeight(3);
    renderer.ellipse (pos.x, pos.y, diameter, diameter);
    renderer.strokeWeight(1);
    renderer.noFill();
    renderer.ellipse (pos.x,pos.y,diameter*10,diameter*10);
    renderer.popMatrix();
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