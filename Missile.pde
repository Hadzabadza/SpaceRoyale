class Missile extends Object { //A class for homing projectiles.
  int timer=Settings.msslSelfDestructTimer;
  int inactivityTimer=Settings.msslInactivityTimer;
  float fuel=Settings.msslFuel;
  PVector accel;
  float boostIntensity;
  Object target;
  float estimatedBoostTime;
  View followerScreen;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Missile (PVector _pos, PVector _vel, float _radius, float _dir, Object _target) {
    super(new PVector(_pos.x, _pos.y), new PVector(_vel.x, _vel.y), _dir, _radius);
    accel=new PVector(0, 0);
    target=_target;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

void turnToTarget() { //MONSTROUS WIP
    /*PVector tempVel=new PVector(vel.x,vel.y);
     PVector targetVel=new PVector(target.vel.x,target.vel.y);
     PVector targetPos=new PVector(target.pos.x,target.pos.y);
     PVector deltaVelocity=new PVector(target.vel.x-vel.x, target.vel.y-vel.y);
     float equalizationTime=deltaVelocity.mag()/Settings.msslAcceleration;
     PVector equalizationPosThis=tempVel.normalize().mult(equalizationTime*equalizationTime/2*Settings.msslAcceleration);
     PVector equalizationPosTarget=targetPos.add(targetVel.mult(equalizationTime));
     float equalizationDist=dist(equalizationPosThis.x,equalizationPosThis.y,equalizationPosTarget.x,equalizationPosTarget.y);
     estimatedBoostTime=equalizationTime+sqrt(2*equalizationDist/Settings.msslAcceleration);
     PVector estimatedPosTarget=new PVector((target.pos.x+target.vel.x*estimatedBoostTime),(target.pos.y+target.vel.y*estimatedBoostTime));
     println(estimatedPosTarget);
     float turnAngle=atan2(estimatedPosTarget.y-pos.y,estimatedPosTarget.x-pos.x);
     println(turnAngle);
     dir=turnAngle;*/
    PVector deltaVelocity=new PVector(target.vel.x-vel.x, target.vel.y-vel.y);
    PVector approachVector=new PVector(target.pos.x-pos.x, target.pos.y-pos.y).normalize();
    float potentialSpeed=Settings.msslAcceleration*fuel-deltaVelocity.mag();
    approachVector.mult(potentialSpeed);
    PVector requiredDirection=approachVector.add(deltaVelocity).normalize();
    //float turnAngle=atan2(target.pos.y-pos.y, target.pos.x-pos.x);
    float turnAngle=atan2(requiredDirection.y, requiredDirection.x);
    turnAngle=atan2(sin(turnAngle-dir), cos(turnAngle-dir));
    if (abs(turnAngle)<=Settings.msslMaxSpin) {
      dir-= turnAngle;
      boost(1);
    } else {
      dir+=Settings.msslMaxSpin*(int)Math.signum(turnAngle);
      //if (abs(turnAngle)<HALF_PI) boost(cos(turnAngle)*cos(turnAngle));
    }
  }

  void boost(float intensity) {
    if (fuel-intensity>0) {
      fuel-=intensity;
      accel.x=Settings.msslAcceleration*cos(dir)*intensity;
      accel.y=Settings.msslAcceleration*sin(dir)*intensity;
      boostIntensity=intensity;
      particles.add(new Particle(sprites.ExhaustSmoke, new PVector(pos.x-25*cos(dir), pos.y-25*sin(dir)), new PVector(vel.x-2*cos(dir), vel.y-2*sin(dir)), random(-PI, PI), color(255, 255*intensity), 0.2, -1, 0.006, random(-0.0005, 0.0005), 250, false));
    }
  }


  void update() {
    boostIntensity=0;
    accel.x=0;
    accel.y=0;
    inactivityTimer--;
    /*if (inactivityTimer>0) {
     boost(1);
     } else {
     if (inactivityTimer==0) {
     if (target!=null) turnToTarget(); 
     else boost(1);
     } else if (inactivityTimer<0) if (estimatedBoostTime>=1) {
     boost(1);
     estimatedBoostTime--;
     } else if (estimatedBoostTime>0) {
     boost(estimatedBoostTime);
     estimatedBoostTime=0;
     }
     }*/
    if (timer--<=0) queueDestroy();
    if (target!=null) {
      if (inactivityTimer>0) boost(1);
      else if (inactivityTimer<0) turnToTarget();
      vel.add(accel);
      if (target.checkCollision(this)) {
        if (target instanceof Ship) { 
          Ship s= (Ship)target;
          s.HP-=Settings.msslDmg;
        }
        if (target instanceof Asteroid) target.queueDestroy();
        queueDestroy();
      }
    } else {
      boost(1);
    }
    super.update();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(PGraphics rr) 
  {
    rr.strokeWeight(1);
    rr.stroke(255*fuel/Settings.msslFuel);
    rr.noFill();
    rr.ellipse(pos.x, pos.y, 100, 100);
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.scale(0.1);
    rr.noTint();
    rr.image(sprites.Missile, -sprites.Missile.width/2, -sprites.Missile.height/2);
    if (boostIntensity>0) {    
      rr.tint(255, boostIntensity*255);
      rr.image(sprites.MissileExhaust, -sprites.Missile.width/2, -sprites.Missile.height/2);
    }
    rr.popMatrix();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////
  
  void spawn() {
    missiles.add(this);
    super.spawn();
  }

  void queueDestroy() {
    int n = round(random(50, 60));
    for (int i=0; i<n; i++) particles.add(new Particle(sprites.Debris[round(random(0, sprites.debrisImages-1))], pos, new PVector(random(-1, 1), random(-1, 1)), random(0, TWO_PI), color(255), 0.35, -1, -0.0001, random(-0.5, 0.5), 255, true));
    destroyees.add(this);
  }

  void destroy() {
    missiles.remove(this);
    if (followerScreen!=null) view.remove(followerScreen);
    super.destroy();
  }
}
