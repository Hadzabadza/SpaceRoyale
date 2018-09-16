class Object { //Superclass for physical ingame objects
  PVector pos;
  PVector vel;
  float dir;
  float radius;
  float diameter;
  boolean destroyed;

  Object(PVector _pos, PVector _vel, float _dir, float _radius) {
    pos=new PVector(_pos.x, _pos.y);
    vel=new PVector(_vel.x, _vel.y);
    dir=_dir;
    radius=_radius;
    diameter=radius*2;
    newSpawns.add(this);
  }

  boolean checkCollision(Object with) {
    if (dist(pos.x, pos.y, with.pos.x, with.pos.y)<=with.radius+radius) return true;
    else return false;
  }
  float checkDist(Object to) {
    return dist(pos.x,pos.y,to.pos.x, to.pos.y);
  }
  void update()
  {
    pos.add(vel);
  }
  void spawn() {
    objects.add(this);
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    destroyed=true;
    objects.remove(this);
  }
  void draw(PGraphics renderer) {
  }
}