class Ship extends Object {
  float warpSpeed=Settings.minWarpSpeed;
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
  int mssls=Settings.msslAmount;
  boolean displayPlanetMap;

  //Controls and inputs
  boolean speedUp;
  boolean slowDown;
  boolean turnLeft;
  boolean turnRight;
  boolean incWarpSpeed;
  boolean decWarpSpeed;
  boolean fire;
  boolean warp;
  boolean turnTurretLeft;
  boolean turnTurretRight;
  boolean zoomIn;
  boolean zoomOut;
  boolean missileAiming;
  int turnWheelInput;

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
    rr.tint(c, 150+100*cos(gameTime));
    rr.image(IMGShipStripes, -IMGShip.width/2, -IMGShip.height/2);
    rr.noTint();
    rr.image(IMGShip, -IMGShip.width/2, -IMGShip.height/2);
    for (int i=1; i<3; i++) {
      PVector msslSlotPos=new PVector(Settings.msslSlotXOffset, Settings.msslSlotYOffset*i);
      if (i<=mssls) rr.image(IMGMissileSlot[0], -IMGMissileSlot[0].width/2+msslSlotPos.x, -IMGMissileSlot[0].height/2+msslSlotPos.y);
      else rr.image(IMGMissileSlot[1], -IMGMissileSlot[1].width/2+msslSlotPos.x, -IMGMissileSlot[1].height/2+msslSlotPos.y);
    }
    rr.popMatrix();
    rr.noFill();
    rr.strokeWeight(1);
    rr.stroke(200);
    PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
    if (Settings.DEBUG) rr.line(pos.x,pos.y,pos.x+vel.x*Settings.FPS,pos.y+vel.y*Settings.FPS);
    rr.pushMatrix();
    rr.translate(turretPos.x, turretPos.y);
    rr.rotate(aimDir);
    rr.scale(0.1);
    rr.image(IMGTurret, -IMGTurret.width/2, -IMGTurret.height/2);
    rr.popMatrix();
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
        land.updateSurfaceImagery();
        land=null;
      }
      /*Warp effects spawner*/ if (frameCount%2==0) particles.add(new Particle(IMGShieldWaves, new PVector(pos.x+40*cos(dir), pos.y+40*sin(dir)), new PVector(0, 0), dir, color(255, 250), 0.35, -1, 0.0026, 0, 250));
    } else
    {
      if (land!=null) { //Check if landed
        if (!checkCollision(land)) //Check if drifted away
        {
          displayPlanetMap=false;
          land.updateSurfaceImagery();
          land=null;
          dock.landingChange(); 
        }
        else {
          vel.x=land.vel.x;
          vel.y=land.vel.y;
        }
      } else {
        for (Planet p : planets) if (checkCollision(p)) //Find which planet collided with (landed on), if any
        {
          land=p;
          vel.x=p.vel.x;
          vel.y=p.vel.y;
          dock.landingChange();
          break;
        }
        for (Star s : stars) if (checkCollision(s)) vel=new PVector(); 
      }
      if (speedUp) if (thrust<=0.99) {
        thrust+=0.01;
        dock.SCUpdateThrustControls=true;
      }
      if (slowDown)if (thrust>=0.01) {
        thrust-=0.01;
        dock.SCUpdateThrustControls=true;
      }
      if (turnLeft) turnLeft();
      else if (turnRight) turnRight();
      else if (turnWheelInput==0) killSpin();
      if (turnWheelInput>1) turnWheelInput--; 
      else if (turnWheelInput==1) {
        turnWheelInput=0;
        turnLeft=false; 
        turnRight=false;
      }
      vel.x+=cos(dir)*thrust*thrust/100; //THRUST APPLICATION
      vel.y+=sin(dir)*thrust*thrust/100;

      /*if (vel.mag()>Settings.shipSpeedLimit) { //SPEED LIMIT
        vel=vel.normalize().mult(Settings.shipSpeedLimit);
      }*/
      /*Thrust exhaust spawner*/ if (thrust>0) if (frameCount%3==0) particles.add(new Particle(IMGExhaustSmoke, new PVector(pos.x-45*cos(-dir), pos.y-45*sin(dir)), new PVector(vel.x-2*cos(dir), vel.y-2*sin(dir)), random(-PI, PI), color(255, 255*thrust), 0.2, -1, 0.006, random(-0.0005, 0.0005), 250));
      super.update(); //OBJECT UPDATE
    }
    if (incWarpSpeed) if (warpSpeed<=Settings.maxWarpSpeed-1) {
      warpSpeed++;
      dock.SCUpdateWarpControls=true;
    }
    if (decWarpSpeed) if (warpSpeed>=Settings.minWarpSpeed+1) {
      warpSpeed--;
      dock.SCUpdateWarpControls=true;
    }
    if (zoomIn) zoomIn();
    if (zoomOut) zoomOut();
    findClosestTarget();
  }

  void turnLeft() {
    spin-=Settings.assistedTurnSpeed*thrust+Settings.staticTurnSpeed;
  };

  void turnRight() {
    spin+=Settings.assistedTurnSpeed*thrust+Settings.staticTurnSpeed;
  };

  void turnLeft(float assistPower) {
    spin-=(assistPower*Settings.assistedTurnSpeed)*thrust+Settings.staticTurnSpeed;
  };

  void turnRight(float assistPower) {
    spin+=(assistPower*Settings.assistedTurnSpeed)*thrust+Settings.staticTurnSpeed;
  };

  void killSpin() {
    spin+=Math.signum(spin)*-1*(Settings.staticTurnSpeed+Settings.assistedTurnSpeed);
  }

  void zoomIn() {
    if (zoom>0.2) zoom*=0.99;
    else zoom=0.2;
  }

  void zoomOut() {
    if (zoom<50) zoom*=1.01;
    else zoom=50;
  }

  void shoot() {
    if (cooldown<=0) {
      PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
      new Bullet(new PVector(turretPos.x, turretPos.y), new PVector(bulSpeed*cos(aimDir)+vel.x, bulSpeed*sin(aimDir)+vel.y), 5, aimDir);
      cooldown=Settings.fireCooldown;
    }
  }

  void fireMissile() {
    if (mssls>0) {
      PVector msslSlotPos=new PVector(pos.x-Settings.msslSlotYOffset*sin(dir)/5*mssls, pos.y-Settings.msslSlotYOffset*cos(dir+PI)/5*mssls);
      Missile ms=new Missile(new PVector(msslSlotPos.x, msslSlotPos.y), new PVector(vel.x, vel.y), 5, dir, target);
      ms.followerScreen=new View(new PVector (100, 100), new PVector(), "Missile "+missiles.size(), missiles.size(), ms);
      mssls--;
    }
  }

  void findClosestTarget() {
    float min;
    min=FMAX;
    target=null;
    for (Object o : objects) {
      distToTarget=this.checkDist(o);
      if ((o!=this)&&!(o instanceof Bullet)&&!(o instanceof Particle)&&!(o instanceof Missile)&&(distToTarget<min)&&(distToTarget<=Settings.targetingDistance)) 
      {
        target=o; 
        min=distToTarget;
      }
    }
    distToTarget=min;
  }

  void drawTarget(PGraphics rr) {
    if ((dock.activePage==3)||(missileAiming))
      if ((distToTarget<Settings.targetingDistance)&&(target!=null)) {
        rr.stroke(200);
        rr.strokeWeight(1);
        rr.noFill();
        for (int i =0; i<3; i++) for (int j=0; j<4; j++) rr.arc(target.pos.x, target.pos.y, target.diameter*1.05+10+(target.diameter*0.05+6)*i, target.diameter*1.05+10+(target.diameter*0.05+6)*i, QUARTER_PI/2+HALF_PI*j+gameTime, (QUARTER_PI+QUARTER_PI/2)+HALF_PI*j+gameTime);
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
    for (int i=0; i<3; i++) particles.add(new Particle(IMGShieldWaves, new PVector(pos.x+60*cos(dir+PI/3*(i-1)), pos.y+60*sin(dir+PI/3*(i-1))), new PVector(warpSpeed*cos(dir+PI/3*(i-1)), warpSpeed*sin(dir+PI/3*(i-1))), dir+PI/3*(i-1), color(255), 0.54, -5, 0.05, 0, 255));
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
    if (warp) stopWarp();
    for (int i=0; i<random(60, 80); i++) {
      float parDir=random(0, TWO_PI);
      particles.add(new Particle(IMGDebris[round(random(0, debrisImages-1))], new PVector(pos.x+random(10, 20)*cos(parDir), pos.y+random(10, 20)*sin(parDir)), new PVector(random(-2, 2), random(-2, 2)), parDir, color(255), 0.7, random(-1, -2), -0.0001, random(-0.5, 0.5), 255));
    }
    radius*=-1;
    diameter*=-1;
    super.destroy();
  }
}
