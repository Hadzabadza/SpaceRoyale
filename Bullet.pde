class Bullet extends Object {
  int timer=Settings.selfDestructTimer;

  Bullet (PVector _pos, PVector _vel, float _radius, float _dir) {
    super(new PVector(_pos.x, _pos.y), new PVector(_vel.x, _vel.y), _dir, _radius);
  }

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
    rr.image(IMGShell, -IMGShell.width/2, -IMGShell.height/2);
    rr.popMatrix();
  }

  void update() {
    pos.add(vel);
    if (timer--<=0) {
      queueDestroy();
    }
    if (Settings.selfDestructTimer-timer>Settings.inactivityTimer) {
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
          sprinkleParticles(IMGDebris, pos, 4, 6);
          queueDestroy();
        }
      }
    }
  }
  void spawn() {
    bullets.add(this);
    super.spawn();
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    bullets.remove(this);
    super.destroy();
  }
}