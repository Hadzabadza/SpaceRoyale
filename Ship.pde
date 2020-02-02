class Ship extends Object {
  float warpSpeed=Settings.minWarpSpeed;
  float turretGfxDiameter=Settings.turretGfxSize;
  float aimDir;
  //PVector grav;
  float thrust;
  float bulSpeed=Settings.projectileSpeed;
  Planet land;
  Planet orbited;
  color c;
  float HP=1;
  float cooldown;
  float zoom=1;
  OscDock dock;
  Object target;
  float distToTarget;
  int mssls=Settings.msslAmount;
  boolean displayPlanetMap;
  float[] heatArray;
  float afterBurner=1;
  float hullPieceArea;
  PImage sprt=sprites.Ship;

  //Graphics
  PGraphics layerUI;
  VelocityIndicator speedometer;
  HeatIndicator thermometer;

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
  boolean afterBurning;
  int turnWheelInput;
  PVector cursor;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Ship() {
    super(new PVector(), new PVector(), 0, Settings.shipSize);
    c=color(100);
    shipInit();
  }
  Ship(color _c) {
    super(new PVector(), new PVector(), 0, Settings.shipSize);
    c=_c;
    shipInit();
  }
  Ship(PVector _pos) {
    super(_pos, new PVector(), 0, Settings.shipSize);
    c=color(0, 255, 0);
    shipInit();
  }
  Ship(PVector _pos, float _dir, color _c, PGraphics _layerUI) {
    super(_pos, new PVector(), _dir, Settings.shipSize);
    c=_c;
    aimDir=_dir;
    layerUI=_layerUI;
    shipInit();
  }

  void shipInit() {
    turretGfxDiameter+=diameter;
    heatArray=new float[32];
    hullPieceArea=diameter*PI/32;
    cursor=new PVector(0.5,0.5);
    speedometer=new VelocityIndicator(width/2,height/2,50,50,this);
    thermometer=new HeatIndicator(width-80,80,50,50,this);
    //for (int i=0; i<heatArray.length; i++) heatArray[i]=i*100;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void shoot() {
    if (cooldown<=0) {
      PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
      new Bullet(new PVector(turretPos.x+vel.x, turretPos.y+vel.y), new PVector(bulSpeed*cos(aimDir)+vel.x, bulSpeed*sin(aimDir)+vel.y), 5, aimDir);
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
      distToTarget=this.getDistTo(o);
      if ((o!=this)&&!(o instanceof Bullet)&&!(o instanceof Particle)&&!(o instanceof Missile)&&(distToTarget<min)&&(distToTarget<=Settings.targetingDistance)) 
      {
        target=o; 
        min=distToTarget;
      }
    }
    distToTarget=min;
  }

  void stopWarp() {
    warp=false;
    for (int i=0; i<3; i++) particles.add(new Particle(sprites.ShieldWaves, new PVector(pos.x+60*cos(dir+PI/3*(i-1)), pos.y+60*sin(dir+PI/3*(i-1))), new PVector(warpSpeed*cos(dir+PI/3*(i-1)), warpSpeed*sin(dir+PI/3*(i-1))), dir+PI/3*(i-1), color(255), 0.54, -5, 0.05, 0, 255, false));
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

  void faceVector(PVector targetDir){
    float dirDiff=VectorAngleDiff(PVector.fromAngle(dir),targetDir);
    
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void update() {
    if (dir<0) dir=TWO_PI+dir;
    else if (dir>0) dir=dir%TWO_PI;
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
      /*Warp effects spawner*/      if (frameCount%2==0) particles.add(new Particle(sprites.ShieldWaves, new PVector(pos.x+40*cos(dir), pos.y+40*sin(dir)), new PVector(0, 0), dir, color(255, 250), 0.35, -1, 0.0026, 0, 250, false));
    } else
    {
      if (land!=null) { //Check if landed
        if (!checkCollision(land)) //Check if drifted away
        {
          displayPlanetMap=false;
          land.updateSurfaceImagery();
          land=null;
          dock.landingChange();
        } else {
          float currDir=land.getDirTo(this);
          float currDist=getDistTo(land);
          if (currDist<land.radius-radius*0.2) {
            //currDist=land.radius;
            vel=land.vel.copy();
          }
          pos.x=land.pos.x+currDist*cos(currDir+land.spin);
          pos.y=land.pos.y+currDist*sin(currDir+land.spin);
        }
      } else {
        for (Planet p : stars.get(0).planets) if (checkCollision(p)) //Find which planet collided with (landed on), if any
        {
          land=p;
          //println(land.ambientTemp);
          if (getDistTo(p)<p.radius-radius*0.2) {
            vel.x=p.vel.x;
            vel.y=p.vel.y;
          }
          dock.landingChange();
          break;
        }
        for (Star s : stars) if (checkCollision(s)) vel=new PVector();
      }
      if (afterBurning) {
        if (land!=null) afterBurner=Settings.afterBurnerMaxCap+land.gravPull/pow(land.radius, 2)*2;
        else afterBurner=Settings.afterBurnerMaxCap;
        thrust=1;
        dock.SCUpdateThrustControls=true;
      }
      else afterBurner=1;
      if (speedUp) if (thrust<=0.99) {
        thrust+=0.01;
        dock.SCUpdateThrustControls=true;
      }
      if (slowDown) if (thrust>=0.01) {
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
      vel.x+=cos(dir)*thrust*thrust/100*afterBurner; //THRUST APPLICATION
      vel.y+=sin(dir)*thrust*thrust/100*afterBurner;

      /*if (vel.mag()>Settings.shipSpeedLimit) { //SPEED LIMIT
       vel=vel.normalize().mult(Settings.shipSpeedLimit);
       }*/
      /*Thrust exhaust spawner*/      
      if (thrust>0) if (frameCount%3==0) particles.add(new Particle(sprites.ExhaustSmoke, new PVector(pos.x+vel.x-45*cos(-dir), pos.y+vel.y-45*sin(dir)), new PVector(vel.x-2*cos(dir)*afterBurner, vel.y-2*sin(dir)*afterBurner), random(-PI, PI), color(255, 150+100/afterBurner, 255/afterBurner, 255*thrust), 0.2*afterBurner, -1, 0.006, random(-0.0005, 0.0005), 250, false));
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
    updateHeat();
    orbited=null;
    for (Planet p:stars.get(0).planets) if (getDistTo(p)<p.gravWellRadius) {
      orbited=p;
      break;
    }
  }

  void zoomIn() {
    if (zoom>Settings.minZoom) zoom*=0.95;
    else zoom=Settings.minZoom;
  }

  void zoomOut() {
    if (zoom<Settings.maxZoom) zoom*=1.05;
    else zoom=Settings.maxZoom;
  }

    void updateHeat() {
    for (int i=0; i<heatArray.length; i++) { //IF first element in array
      if (i==0) {
        heatFunction(0, heatArray.length-1, 1);
      } else if (i==heatArray.length-1) { //IF last element in array
        heatFunction(i, i-1, 0);
      } else { //If any other element in array
        heatFunction(i, i-1, i+1);
      }
    }
  }

  void heatFunction(int mid, int left, int right) {
    //RADIATION
    float heatRad=(heatArray[mid]/Settings.hullPieceMass)*hullPieceArea/Settings.FPS;
    heatArray[left]+=heatRad;
    heatArray[right]+=heatRad;
    heatArray[mid]-=heatRad*3;
    
    //CONDUCTION
    float heatConduction=0;
    if (heatArray[left]<heatArray[mid]) {
      heatConduction=(heatArray[mid]-heatArray[left])*Settings.heatConductivityRate;
      heatArray[left]+=heatConduction;
      heatArray[mid]-=heatConduction;
    }
    if (heatArray[right]<heatArray[mid]) {
      heatConduction=(heatArray[mid]-heatArray[right])*Settings.heatConductivityRate;
      heatArray[right]+=heatConduction;
      heatArray[mid]-=heatConduction;
    }
  }

  void heatUpSide(float rad, float energy) {
    if (dir>rad) rad+=TWO_PI;
    rad=(rad-dir)%TWO_PI;
    int index=floor(rad/(QUARTER_PI/4)); 
    if (index<0) index=heatArray.length-index;
    if (index>=heatArray.length) index-=heatArray.length;
    //if (heatArray[index]<temp)
    heatArray[index]+=energy;//energy*(pow(1-heatArray[index]/temp,2));
    //println(energy+" "+heatArray[index]);
    //if (temp>heatArray[index]) heatArray[index]+=(temp-heatArray[index])*energy/Settings.FPS;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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

  void draw(PGraphics rr) {
    /*rr.stroke(c);
     rr.fill(255);
     rr.line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
     rr.ellipse(pos.x, pos.y, diameter, diameter);*/
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.scale(Settings.shipDrawScale);
    rr.tint(c, 150+100*cos(gameTime));
    rr.image(sprites.ShipStripes, -sprt.width/2, -sprt.height/2);
    rr.noTint();
    rr.image(sprt, -sprt.width/2, -sprt.height/2);
    for (int i=1; i<3; i++) {
      PVector msslSlotPos=new PVector(Settings.msslSlotXOffset, Settings.msslSlotYOffset*i);
      if (i<=mssls) rr.image(sprites.MissileSlot[0], -sprites.MissileSlot[0].width/2+msslSlotPos.x, -sprites.MissileSlot[0].height/2+msslSlotPos.y);
      else rr.image(sprites.MissileSlot[1], -sprites.MissileSlot[1].width/2+msslSlotPos.x, -sprites.MissileSlot[1].height/2+msslSlotPos.y);
    }
    rr.popMatrix();

    rr.strokeWeight(1);
    if (zoom<Settings.maxZoom*0.5) {
      if (orbited!=null){
        rr.fill(200);
        speedometer.draw(stars.get(0),color(200,12.75*zoom),layerUI);
        speedometer.draw(orbited,color(0,200,0,12.5*(25-zoom)),layerUI);
      } else speedometer.draw(stars.get(0),color(200),layerUI);
    }
    else speedometer.draw(stars.get(0),color(200),layerUI);

    rr.pushMatrix();
    PVector turretPos=new PVector(pos.x-Settings.turretXOffset*cos(dir)-Settings.turretYOffset*sin(dir), pos.y-Settings.turretXOffset*sin(dir)-Settings.turretYOffset*cos(dir+PI));
    rr.translate(turretPos.x, turretPos.y);
    rr.rotate(aimDir);
    rr.scale(0.1);
    rr.image(sprites.Turret, -sprites.Turret.width/2, -sprites.Turret.height/2);
    rr.popMatrix();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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
      particles.add(new Particle(sprites.Debris[round(random(0, sprites.debrisImages-1))], new PVector(pos.x+random(10, 20)*cos(parDir), pos.y+random(10, 20)*sin(parDir)), new PVector(random(-2, 2), random(-2, 2)), parDir, color(255), 0.7, random(-1, -2), -0.0001, random(-0.5, 0.5), 255, true));
    }
    radius*=-1;
    diameter*=-1;
    super.destroy();
  }
}
