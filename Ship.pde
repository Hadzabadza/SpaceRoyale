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
  OscDock dock;
  Object target;
  float distToTarget;

  //Controls and inputs
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
    c=color(100);
  }
  Ship(color _c) {
    super(new PVector(), new PVector(), 0, Settings.shipSize);
    turretGfxDiameter+=diameter;
    c=_c;
  }
  Ship(PVector _pos) {
    super(_pos, new PVector(), 0, Settings.shipSize);
    turretGfxDiameter+=diameter;
    c=color(0, 255, 0);
  }
  void draw(PGraphics rr) {
    /*rr.stroke(c);
    rr.fill(255);
    rr.line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
    rr.ellipse(pos.x, pos.y, diameter, diameter);*/
    rr.pushMatrix();
    rr.translate(pos.x,pos.y);
    rr.rotate(dir);
    rr.scale(0.2);
    rr.image(IMGShip,-IMGShip.width/2,-IMGShip.height/2);
    rr.popMatrix();
    rr.noFill();
    rr.stroke(200);
    rr.line(pos.x+12*cos(aimDir), pos.y+12*sin(aimDir), pos.x+40*cos(aimDir), pos.y+40*sin(aimDir));
    rr.arc(pos.x, pos.y, turretGfxDiameter, turretGfxDiameter, aimDir-1, aimDir+1);
    if (warp)
    {
      rr.stroke(0, 0, 255);
      rr.line(pos.x+100*cos(dir-PI)-10*sin(dir-PI), pos.y+100*sin(dir-PI)+10*cos(dir-PI), pos.x-100*cos(dir-PI)-10*sin(dir-PI), pos.y-100*sin(dir-PI)+10*cos(dir-PI));
      rr.line(pos.x+100*cos(dir-PI)-10*sin(dir), pos.y+100*sin(dir-PI)+10*cos(dir), pos.x-100*cos(dir-PI)-10*sin(dir), pos.y-100*sin(dir-PI)+10*cos(dir));
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
      pos.x+=warpSpeed*cos(dir);
      pos.y+=warpSpeed*sin(dir);
      if (land!=null) {
        dock.landingChange();
        land=null;
      }
    } else
    {
      if (land!=null) { //Check if landed
        if (!checkCollision(land)) dock.landingChange(); //Check if drifted away
      } else {
        for (Planet p : planets) if (checkCollision(p))
        {
          land=p;
          vel.x=p.vel.x;
          vel.y=p.vel.y;
          dock.landingChange();
          break;
        }
        for (Star s : stars) if (checkCollision(s)) vel=new PVector();
      }
      if (speedUp) if (thrust<=0.99) thrust+=0.01;
      if (slowDown)if (thrust>=0.01) thrust-=0.01;
      if (turnLeft) dir-=0.1*thrust+0.03;
      if (turnRight) dir+=0.1*thrust+0.03;
      if (zoomIn) zoomIn();
      if (zoomOut) zoomOut();
      vel.x+=cos(dir)*thrust*thrust/100;
      vel.y+=sin(dir)*thrust*thrust/100;
      super.update();
      findClosestTarget();
    }
  }

  void zoomIn() {
    if (zoom>0.3) zoom*=0.99;
    else zoom=0.3;
  }
  void zoomOut() {
    if (zoom<9.3) zoom*=1.01;
    else zoom=9.3;
  }

  void shoot() {
    if (cooldown<=0) {
      float offDis=radius+turretGfxDiameter/2;
      new Bullet(new PVector(pos.x+offDis*cos(aimDir),pos.y+offDis*sin(aimDir)),new PVector(bulSpeed*cos(aimDir)+vel.x, bulSpeed*sin(aimDir)+vel.y),aimDir, 3);
      cooldown=Settings.fireCooldown;
    }
  }

  void findClosestTarget() {
    float min;
    target=objects.get(0);
    min=this.checkDist(target);
    for (int i=1; i<objects.size(); i++) {
      Object chk=objects.get(i);
      distToTarget=this.checkDist(chk);
      if ((distToTarget<min)&&(chk!=this)&&!(chk instanceof Bullet)) 
      {
        target=chk; 
        min=distToTarget;
      }
    }
    distToTarget=min;
  }
  
  void drawTarget(PGraphics renderer) {
    if (dock.activePage==3)
    if ((distToTarget<Settings.targetingDistance)&&(target!=null)) {
      renderer.stroke(200);
      renderer.strokeWeight(1);
      renderer.noFill();
      for (int i =0; i<3; i++) for (int j=0; j<4; j++) renderer.arc(target.pos.x, target.pos.y, target.diameter*1.05+10+(target.diameter*0.05+6)*i, target.diameter*1.05+10+(target.diameter*0.05+6)*i, QUARTER_PI/2+HALF_PI*j+frameCount, (QUARTER_PI+QUARTER_PI/2)+HALF_PI*j+frameCount);
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
    radius*=-1;
    diameter*=-1;
    super.destroy();
  }
}