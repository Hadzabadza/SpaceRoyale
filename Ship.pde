class Ship {
  boolean warp;
  float warpSpeed=10;
  float dir=0;
  PVector vel, pos, grav;
  float thrust=0;
  Planet land;

  Ship() {
    vel = new PVector();
    pos= new PVector();
    pos.x=0;
    pos.y=0;
  }
  void draw() {
    stroke(255, 0, 0);
    fill(255);
    line(pos.x, pos.y, pos.x+100*cos(radians(dir)), pos.y+100*sin(radians(dir)));
    ellipse(pos.x, pos.y, 15, 15);
  }

  void update() {
    if (warp)
    {
      pos.x+=warpSpeed*cos(radians(dir));
      pos.y+=warpSpeed*sin(radians(dir));
      stroke(0, 0, 255);
      line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir-180)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir-180)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir-180)));
      line(pos.x+100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y+100*sin(radians(dir-180))+10*cos(radians(dir)), pos.x-100*cos(radians(dir-180))-10*sin(radians(dir)), pos.y-100*sin(radians(dir-180))+10*cos(radians(dir)));
      /*mod.offset.setLastValue(800);
       mod.setAmplitude(100);*/
    } else
    {
      /*mod.offset.setLastValue(440*thrust*thrust);
       mod.setAmplitude(0);*/
      for (Star s : stars)
      {
        if (dist(pos.x, pos.y, s.pos.x, s.pos.y)<=s.radius)
        {
          vel.x=0;
          vel.y=0;
        }
      }
      for (Planet p : planets)
      {
        if (dist(pos.x, pos.y, p.pos.x, p.pos.y)<=p.radius)
        {
          land=p;
          vel.x=p.vel.x;
          vel.y=p.vel.y;
          break;
        } else
        {
          land=null;
        }
      }
      if (move[0]) {
        if (thrust<=0.99)
          thrust+=0.01;
      }
      if (move[1]) {
        dir-=4*thrust+1;
      }
      if (move[2]) {
        if (thrust>=0.01)
          thrust-=0.01;
      }
      if (move[3]) {
        dir+=4*thrust+1;
      }
      vel.x+=cos(radians(dir))*thrust*thrust/100;
      vel.y+=sin(radians(dir))*thrust*thrust/100;
      pos.x+=vel.x;
      pos.y+=vel.y;
    }
  }
  void toggleWarp() {
  }
}