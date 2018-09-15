class Bullet extends Object {
  int timer=1200;

  Bullet (PVector _pos, PVector _vel, float _radius) {
    super(new PVector(_pos.x, _pos.y), new PVector(_vel.x, _vel.y), 0, _radius);
  }

  void draw() 
  {
    fill(255, 0, 0);
    strokeWeight(1);
    stroke (255);
    ellipse (pos.x, pos.y, diameter, diameter);
  }

  void update() {
    pos.add(vel);
    if (timer--<=0) {
      queueDestroy();
    }
    for (int j=asteroids.size()-1; j>=0; j--)
    {
      Asteroid a=asteroids.get(j);
      if (checkCollision(a))
      {
        a.queueDestroy();
        queueDestroy();
      }
    }
  }
  void spawn(){
    bullets.add(this);
    super.spawn();
  }
  void queueDestroy(){
    destroyees.add(this);
  }
  void destroy() {
    bullets.remove(this);
    super.destroy();
  }
}