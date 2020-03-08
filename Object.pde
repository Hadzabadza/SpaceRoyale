class Object { //Superclass for physical ingame objects
  PVector pos;
  PVector vel;
  float dir;
  float spin;
  float radius;
  float diameter;
  boolean destroyed;
  boolean active=true;

  private Object(){}

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Object(PVector _pos, PVector _vel, float _dir, float _radius) {
    pos=new PVector(_pos.x, _pos.y);
    vel=new PVector(_vel.x, _vel.y);
    dir=_dir;
    radius=_radius;
    diameter=radius*2;
    newSpawns.add(this);
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  boolean checkCollision(Object with) {
    if (dist(pos.x, pos.y, with.pos.x, with.pos.y)<=with.radius+radius) return true;
    else return false;
  }
  float getDistTo(Object to) {
    return dist(pos.x,pos.y,to.pos.x, to.pos.y);
  }
  float getDirTo(Object to) {
    PVector checker=new PVector(to.pos.x-pos.x,to.pos.y-pos.y);
    float direction=checker.heading();
    if (checker.y<0) direction=TWO_PI+direction;
    return direction; 
  }
  PVector getVectorTo(Object to){
    return (new PVector(to.pos.x-pos.x,to.pos.y-pos.y));
  }

  PVector calculateGravPull(Object pulled, float pullStrength, float currDist){ //Universal grav function (might be a bad idea)
    return pulled.getVectorTo(this).normalize().mult(pullStrength/pow(currDist, Settings.gravdient)*Settings.gravMod);
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void update()
  {
    pos.add(vel);
    dir+=spin;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void softDraw(PGraphics renderer){  }
  void draw(PGraphics renderer){  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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
}
