class Ship extends Object{
  float warpSpeed=warpCap;
  float turretGfxDiameter=turretGfxSize;
  float aimDir;
  //PVector grav;
  float thrust;
  float bulSpeed=projectileSpeed;
  Planet land;
  color c;
  
  boolean speedUp;
  boolean slowDown;
  boolean turnLeft;
  boolean turnRight;
  boolean fire;
  boolean warp;
  boolean turnTurretLeft;
  boolean turnTurretRight;

  Ship() {
    super(new PVector(), new PVector(),0,shipSize);
    turretGfxDiameter+=diameter;
    c=color(0,255,0);
  }
  Ship(PVector _pos) {
    super(_pos, new PVector(),0,shipSize);
    turretGfxDiameter+=diameter;
    c=color(0,255,0);
  }
  void draw() {
    stroke(c);
    fill(255);
    line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
    ellipse(pos.x, pos.y, diameter, diameter);
    noFill();
    stroke(255, 0, 0);
    line(pos.x+12*cos(aimDir), pos.y+12*sin(aimDir), pos.x+40*cos(aimDir), pos.y+40*sin(aimDir));
    arc(pos.x, pos.y, turretGfxDiameter, turretGfxDiameter,aimDir-1,aimDir+1);
  }

  void update() {
    if (turnTurretLeft) aimDir-=0.042;
    if (turnTurretRight) aimDir+=0.042;
    if (fire) shoot();
    if (warp)
    {
      pos.x+=warpSpeed*cos(radians(dir));
      pos.y+=warpSpeed*sin(radians(dir));
      stroke(0, 0, 255);
      line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir-180)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir-180)));
      line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir)));
      /*mod.offset.setLastValue(800);
       mod.setAmplitude(100);*/
    } else
    {
      /*mod.offset.setLastValue(440*thrust*thrust);
       mod.setAmplitude(0);*/
      for (Star s : stars)
      {
        if (checkCollision(s))
        {
          vel.x=0;
          vel.y=0;
        }
      }
      for (Planet p : planets)
      {
        if (checkCollision(p))
        {
          land=p;
          vel.x=p.vel.x;
          vel.y=p.vel.y;
          break;
        } else
        {
          land=null;
        }
      }
      if (speedUp) {
        if (thrust<=0.99)
          thrust+=0.01;
      }
      if (slowDown) {
        if (thrust>=0.01)
          thrust-=0.01;
      }
      if (turnLeft) dir-=4*thrust+1;
      if (turnRight) dir+=4*thrust+1;
      vel.x+=cos(radians(dir))*thrust*thrust/100;
      vel.y+=sin(radians(dir))*thrust*thrust/100;
      super.update();
    }
  }
  void shoot(){
    float offDis=radius+turretGfxDiameter/2;
    new Bullet(new PVector(pos.x+offDis*cos(aimDir),pos.y+offDis*sin(aimDir)),new PVector(bulSpeed*cos(aimDir)+vel.x,bulSpeed*sin(aimDir)+vel.y),3);
  }
  void spawn(){
    ships.add(this);
    super.spawn();
  }
  void queueDestroy(){
    destroyees.add(this);
  }
  void destroy(){
    ships.remove(this);
    super.destroy();
  }
}