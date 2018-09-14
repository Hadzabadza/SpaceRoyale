class Bullet extends Object{
  int timer=1200;

  Bullet (PVector _pos, PVector _vel, float _radius) {
    super(new PVector(_pos.x, _pos.y),new PVector(_vel.x, _vel.y),0,_radius);
  }

  void draw() 
  {
    fill(255, 0, 0);
    strokeWeight(1);
    stroke (255);
    ellipse (pos.x, pos.y, radius*2, radius*2);
  }

  void update() {
    pos.add(vel);
    for (int j=asteroids.size()-1; j>=0; j--)
    {
      Asteroid a=asteroids.get(j);
      {
        if (dist(pos.x, pos.y, a.pos.x, a.pos.y)<=a.radius+radius)
        {
          asteroids.remove(a);
          bullets.remove(this);
        }
      }
      if (timer--<=0) {
        bullets.remove(this);
      }
    }
  }
  void destroy(){
    bullets.remove(this);
    super.destroy();
  }
}