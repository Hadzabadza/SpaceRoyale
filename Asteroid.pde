class Asteroid {
  float mass;
  float radius;
  float AOE;
  float distance;
  PVector pos;
  PVector vel;
  PVector grav;
  Star orbitStar;

  Asteroid (Star s, float mas, float distS) {
    orbitStar=s;
    pos= new PVector();
    vel= new PVector();
    mass=mas;
    radius=sqrt(mass)*5;
    distance = distS+orbitStar.radius;
    float phase=random(0, 360);
    vel.x=sqrt(0.0001*distance)*cos(radians(phase+90));
    vel.y=sqrt(0.0001*distance)*sin(radians(phase+90));
    pos.x=orbitStar.pos.x+distance*cos(radians(phase));
    pos.y=orbitStar.pos.y+distance*sin(radians(phase));
  }

  void draw() 
  {
    pushMatrix();
    translate(0, 0, -1);
    stroke(255, 105+55*cos(radians(frameCount)),105+55*cos(radians(frameCount)),125+75*cos(radians(frameCount)));
    noFill();
    ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    popMatrix();

    pushMatrix();
    translate(0, 0, 1);
    fill(200,20,100);
    strokeWeight(3);
    ellipse (pos.x, pos.y, radius*2, radius*2);
    strokeWeight(1);
    noFill();
    ellipse (pos.x,pos.y,radius*20,radius*20);
    popMatrix();
  }

  void update() {
    grav=new PVector();
    grav.x=-(pos.x-orbitStar.pos.x);
    grav.y=-(pos.y-orbitStar.pos.y);
    grav.normalize();
    grav.mult(0.0001);
    vel.add(grav);
    pos.add(vel);
  }
}