class Planet extends Object{
  PImage surface;
  PImage map;
  float mass;
  float distance;
  float spin;
  float avgHeight=122;
  float minHeight=255;
  float maxHeight=0;
  float totalHeight=0;
  int mapRes;
  int orbitNumber;
  PVector grav;
  Terrain [] terrain;
  Terrain selected;
  Star orbitStar;

  Planet(Star s, float mas, float distS, int number) {
    super(new PVector(),new PVector(),0,sqrt(mas)*5);
    orbitStar=s;
    mass=mas;
    distance = distS+orbitStar.radius;
    float phase=random(0, 360);
    vel.x=sqrt(0.0001*distance)*cos(radians(phase+90));
    vel.y=sqrt(0.0001*distance)*sin(radians(phase+90));
    pos.x=orbitStar.pos.x+distance*cos(radians(phase));
    pos.y=orbitStar.pos.y+distance*sin(radians(phase));
    spin=random(-1, 1);
    orbitNumber=number;
    surface=createImage((int)radius*4, (int)radius*4, ARGB);
    terrain=new Terrain[surface.width*surface.height];
    mapRes=floor(width/(surface.width+20));
    surface.loadPixels();
    float seaLevel=random(40, 180);
    float noiseOffset=orbitNumber*10000;
    float prevT=seaLevel;
    for (int y=0; y<surface.height; y++)
    { 
      for (int x=0; x<surface.width; x++)
      { 
        prevT=noise(float(x)/100+noiseOffset, float(y)/100+noiseOffset)*seaLevel;
        totalHeight+=prevT;
        terrain[x+y*surface.height]=(new Terrain(x, y, prevT, this, x+y*surface.height));
        surface.pixels[y*surface.height+x]=color(round(terrain[x+y*surface.height].elevation));
        avgHeight=(avgHeight+terrain[x+y*surface.height].elevation)/2;
        if (minHeight>terrain[x+y*surface.height].elevation)
          minHeight=terrain[x+y*surface.height].elevation;
        if (maxHeight<terrain[x+y*surface.height].elevation)
          maxHeight=terrain[x+y*surface.height].elevation;
      }
    }
    for (Terrain t : terrain)
    { 
      if (t.elevation>minHeight+(avgHeight-minHeight)*0.4)
      {
        t.fill=color(map(t.elevation, minHeight, maxHeight, 255, 0), map(t.elevation, minHeight, maxHeight, 0, 255), 0);
      } else
      {
        t.water=true;
        t.fill=color(0, 0, map(t.elevation, minHeight*0.5, (minHeight+(avgHeight-minHeight)*0.4)*1.3, 0, 255));
        t.depth=map(t.elevation, minHeight, (minHeight+(avgHeight-minHeight)*0.4), 1, 0);
        surface.pixels[t.y*surface.height+t.x]=t.fill;
      }
    }
    surface.updatePixels();
    map=createImage(surface.width*mapRes, surface.height*mapRes, ARGB);
    map.loadPixels();
    for (int y = 0; y < surface.height; y++) {
      for (int x = 0; x < surface.width; x++) {
        for (int ry = 0; ry < mapRes; ry++) {
          for (int rx=0; rx < mapRes; rx++) {
            map.pixels[x * mapRes + rx + y * mapRes * map.height + ry * map.height] = surface.pixels[x + y * surface.height];
          }
        }
      }
    }
    for (int i=0; i<surface.height; i++)
    {
      for (int j=0; j<surface.width; j++)
      {
        if ((j>(surface.width-1)/2+sqrt(sq(surface.width/2)-sq(surface.width/2-i)))||(j<(surface.width+1)/2-sqrt(sq(surface.width/2)-sq(surface.width/2-i))))
        {
          surface.pixels[(int)i*surface.height+(int)j]=color(0, 0);
        }
      }
    }
    map.updatePixels();
  }

  void draw() 
  {
    pushMatrix();
    translate(0, 0, -1);
    stroke(255, 125+75*cos(radians(frameCount)));
    noFill();
    ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    popMatrix();

    pushMatrix();
    translate(0, 0, 1);
    noFill();
    strokeWeight(3);
    ellipse (pos.x, pos.y, diameter, diameter);
    strokeWeight(1);
    ellipse (pos.x,pos.y,diameter*10,diameter*10);
    popMatrix();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate((radians(frameCount))/4*spin);
    image(surface, 0-surface.width/(surface.width/radius), 0-surface.height/(surface.height/radius), surface.width/2, surface.height/2);
    popMatrix();
    if (frameCount%5==0)
    {
      totalHeight=0;
      minHeight=99999;
      maxHeight=-99999;
      for (int y=0; y<surface.height; y++)
      { 
        for (int x=0; x<surface.width; x++)
        { 
          totalHeight+=terrain[x+y*surface.height].elevation;
          avgHeight=(avgHeight+terrain[x+y*surface.height].elevation)/2;
          if (minHeight>terrain[x+y*surface.height].elevation)
            minHeight=terrain[x+y*surface.height].elevation;
          if (maxHeight<terrain[x+y*surface.height].elevation)
            maxHeight=terrain[x+y*surface.height].elevation;
        }
      }
    }
  }

  void update() {
    grav=new PVector();
    grav.x=-(pos.x-orbitStar.pos.x);
    grav.y=-(pos.y-orbitStar.pos.y);
    grav.normalize();
    grav.mult(0.0001);
    vel.add(grav);
    super.update();
  }

  Terrain pickTile() {
    int xOffset=(width-ship.land.map.width)/2;
    int yOffset=(height-ship.land.map.height)/2;
    float halfRes=mapRes/2;
    if (cursor.x>xOffset-halfRes&&cursor.x<width-xOffset-halfRes&&cursor.y>yOffset-halfRes&&cursor.y<height-yOffset-halfRes) {
      int x=round((cursor.x-xOffset)/mapRes);
      int y=round((cursor.y-yOffset)/mapRes);
      selected=terrain[x+y*surface.height];

      return selected;
    } else
    {
      selected=null;
      return null;
    }
  }
  void spawn(){
    planets.add(this);
    super.spawn();
  }
  void queueDestroy(){
    destroyees.add(this);
  }
  void destroy(){
    planets.remove(this);
    super.destroy();
  }
}