class Ship extends Object {
  float warpSpeed=Settings.warpCap;
  float turretGfxDiameter=Settings.turretGfxSize;
  float aimDir;
  //PVector grav;
  float thrust;
  float bulSpeed=Settings.projectileSpeed;
  Planet land;
  color c;
  float HP=1;
  float cooldown;
  float zoom=1;

  boolean speedUp;
  boolean slowDown;
  boolean turnLeft;
  boolean turnRight;
  boolean fire;
  boolean warp;
  boolean turnTurretLeft;
  boolean turnTurretRight;
  boolean zoomIn;
  boolean zoomOut;

  Ship() {
    super(new PVector(), new PVector(), 0, Settings.shipSize);
    turretGfxDiameter+=diameter;
    c=color(0, 255, 0);
  }
  Ship(PVector _pos) {
    super(_pos, new PVector(), 0, Settings.shipSize);
    turretGfxDiameter+=diameter;
    c=color(0, 255, 0);
  }
  void draw(PGraphics rr) {
    rr.stroke(c);
    rr.fill(255);
    rr.line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
    rr.ellipse(pos.x, pos.y, diameter, diameter);
    rr.noFill();
    rr.stroke(255, 0, 0);
    rr.line(pos.x+12*cos(aimDir), pos.y+12*sin(aimDir), pos.x+40*cos(aimDir), pos.y+40*sin(aimDir));
    rr.arc(pos.x, pos.y, turretGfxDiameter, turretGfxDiameter, aimDir-1, aimDir+1);
    if (warp)
    {
      rr.stroke(0, 0, 255);
      rr.line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir-180)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir-180)));
      rr.line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir)));
    }
  }

  void update() {
    if (cooldown>0) cooldown-=0.01;
    if (HP<=0) queueDestroy();
    if (turnTurretLeft) aimDir-=0.042;
    if (turnTurretRight) aimDir+=0.042;
    if (fire) shoot();
    if (warp)
    {
      pos.x+=warpSpeed*cos(radians(dir));
      pos.y+=warpSpeed*sin(radians(dir));
    } else
    {
      for (Star s : stars) if (checkCollision(s)) vel=new PVector();
      for (Planet p : planets)
      {
        if (checkCollision(p))
        {
          land=p;
          vel.x=p.vel.x;
          vel.y=p.vel.y;
          break;
        } else land=null;
      }
      if (speedUp) if (thrust<=0.99) thrust+=0.01;
      if (slowDown)if (thrust>=0.01) thrust-=0.01;
      if (turnLeft) dir-=4*thrust+1;
      if (turnRight) dir+=4*thrust+1;
      if (zoomIn) zoom*=0.99;
      else if (zoomOut) zoom*=1.01;
      vel.x+=cos(radians(dir))*thrust*thrust/100;
      vel.y+=sin(radians(dir))*thrust*thrust/100;
      super.update();
    }
  }
  void shoot() {
    if (cooldown<=0) {
      float offDis=radius+turretGfxDiameter/2;
      new Bullet(new PVector(pos.x+offDis*cos(aimDir), pos.y+offDis*sin(aimDir)), new PVector(bulSpeed*cos(aimDir)+vel.x, bulSpeed*sin(aimDir)+vel.y), 3);
      cooldown=Settings.fireCooldown;
    }
  }
  void spawn(int which) {
    ships[which]=this;
    super.spawn();
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    //ships.remove(this);
    super.destroy();
  }
}