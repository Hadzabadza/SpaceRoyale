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
  Ship(PVector _pos, float _dir, color _c) {
    super(_pos, new PVector(), _dir, Settings.shipSize);
    turretGfxDiameter+=diameter;
    c=_c;
    aimDir=_dir;
  }
  void draw(PGraphics rr) {
    /*rr.stroke(c);
     rr.fill(255);
     rr.line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
     rr.ellipse(pos.x, pos.y, diameter, diameter);*/
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.scale(0.2);
    rr.tint(c);
    rr.image(IMGShipStripes, -IMGShip.width/2, -IMGShip.height/2);
    rr.noTint();
    rr.image(IMGShip, -IMGShip.width/2, -IMGShip.height/2);
    rr.popMatrix();
    rr.noFill();
    rr.strokeWeight(1);
    rr.stroke(200);
    PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
    rr.pushMatrix();
    rr.translate(turretPos.x, turretPos.y);
    rr.rotate(aimDir);
    rr.scale(0.1);
    rr.image(IMGTurret, -IMGTurret.width/2, -IMGTurret.height/2);
    rr.popMatrix();

    if (warp) if (frameCount%2==0) particles.add(new Particle(IMGShieldWaves, new PVector(pos.x+40*cos(dir), pos.y+40*sin(dir)), new PVector(0, 0), dir, color(255, 250), 0.35, -1, 0.0026, 0, 250));
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
      if (turnLeft) dir-=Settings.assistedTurnSpeed*thrust+Settings.staticTurnSpeed;
      if (turnRight) dir+=Settings.assistedTurnSpeed*thrust+Settings.staticTurnSpeed;
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
      PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
      new Bullet(new PVector(turretPos.x, turretPos.y), new PVector(bulSpeed*cos(aimDir)+vel.x, bulSpeed*sin(aimDir)+vel.y), 5, aimDir);
      cooldown=Settings.fireCooldown;
    }
  }

  void findClosestTarget() {
    float min;
    min=FMAX;
    for (Object o : objects) {
      distToTarget=this.checkDist(o);
      if ((o!=this)&&!(o instanceof Bullet)&&!(o instanceof Particle)&&(distToTarget<min)) 
      {
        target=o; 
        min=distToTarget;
      }
    }
    distToTarget=min;
  }

  void drawTarget(PGraphics rr) {
    if (dock.activePage==3)
      if ((distToTarget<Settings.targetingDistance)&&(target!=null)) {
        rr.stroke(200);
        rr.strokeWeight(1);
        rr.noFill();
        for (int i =0; i<3; i++) for (int j=0; j<4; j++) rr.arc(target.pos.x, target.pos.y, target.diameter*1.05+10+(target.diameter*0.05+6)*i, target.diameter*1.05+10+(target.diameter*0.05+6)*i, QUARTER_PI/2+HALF_PI*j+radians(frameCount), (QUARTER_PI+QUARTER_PI/2)+HALF_PI*j+radians(frameCount));
      }
  }
  void drawAim(PGraphics rr) {
    if (!destroyed) {
      PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
      rr.stroke(200);
      rr.noFill();
      rr.strokeWeight(1);
      rr.line(turretPos.x+turretGfxDiameter/2*cos(aimDir), turretPos.y+turretGfxDiameter/2*sin(aimDir), turretPos.x+(turretGfxDiameter/2+20)*cos(aimDir), turretPos.y+(turretGfxDiameter/2+20)*sin(aimDir));
      rr.arc(turretPos.x, turretPos.y, turretGfxDiameter, turretGfxDiameter, aimDir-0.5, aimDir+0.5);
    }
  }

  void stopWarp() {
    warp=false;
    for (int i=0; i<3; i++) particles.add(new Particle(IMGShieldWaves, new PVector(pos.x+60*cos(dir+PI/3*(i-1)), pos.y+60*sin(dir+PI/3*(i-1))), new PVector(10*cos(dir+PI/3*(i-1)), 10*sin(dir+PI/3*(i-1))), dir+PI/3*(i-1), color(255), 0.54, -5, 0.05, 0, 255));
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