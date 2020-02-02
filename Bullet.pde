class Bullet extends Object {
  int timer=Settings.bullSelfDestructTimer;
  int inactivityTimer=Settings.bullInactivityTimer;
  
//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Bullet (PVector _pos, PVector _vel, float _radius, float _dir) {
    super(new PVector(_pos.x, _pos.y), new PVector(_vel.x, _vel.y), _dir, _radius);
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

  void update() {
    pos.add(vel);
    if (timer--<=0) {
      queueDestroy();
    }
    if (inactivityTimer--<=0) {
      for (int j=asteroids.size()-1; j>=0; j--)
      {
        Asteroid a=asteroids.get(j);
        if (checkCollision(a))
        {
          a.queueDestroy();
          queueDestroy();
        }
      }
      for (Ship s : ships)
      {
        if (checkCollision(s))
        {
          s.HP-=Settings.bullDmg;
          queueDestroy();
        }
      }
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(PGraphics rr) 
  {
    /*
    rr.fill(255, 0, 0);
     rr.strokeWeight(1);
     rr.stroke (255);
     rr.ellipse (pos.x, pos.y, diameter, diameter);
     */
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.scale(0.15);
    rr.noTint();
    rr.image(sprites.Shell, -sprites.Shell.width/2, -sprites.Shell.height/2);
    rr.popMatrix();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////


  void spawn() {
    bullets.add(this);
    super.spawn();
  }
  void queueDestroy() {
    int n = round(random(30, 40));
    for (int i=0; i<n; i++) particles.add(new Particle(sprites.Debris[round(random(0, sprites.debrisImages-1))], pos, new PVector(random(-0.5,0.5),random(-0.5,0.5)),random(0,TWO_PI),color(255),0.2,-1,-0.0001,random(-0.5,0.5),255, true));
    destroyees.add(this);
  }
  void destroy() {
    bullets.remove(this);
    super.destroy();
  }
}
