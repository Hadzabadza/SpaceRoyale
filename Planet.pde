class Planet extends Object {
  PImage surface;
  //PImage surfaceImage;
  Map surfaceScreen;
  float mass;
  float distance;
  float spin;
  float avgHeight=122;
  float minHeight=255;
  float maxHeight=0;
  float totalHeight=0;
  float waterLevel=0;
  int gravWellRadius;
  int gravWellDiameter;
  float gravPull;
  int mapRes;
  int orbitNumber;
  PVector grav;
  IntDict terrainUpdateQueue;
  Terrain [] terrain;
  Terrain selected;
  Star orbitStar;

  Planet(Star s, float mas, float distS, int number) {
    super(new PVector(), new PVector(), 0, sqrt(mas)*20);
    orbitStar=s;
    mass=mas;
    distance = distS+orbitStar.radius;
    gravPull=mass/5000;
    gravWellRadius=round(radius*Settings.gravityWellRadiusMultiplier);
    gravWellDiameter=gravWellRadius*2;
    waterLevel=random(0.1, 0.9);
    float phase=random(0, TWO_PI);
    vel.x=sqrt(Settings.celestialPull*distance)*cos(phase+HALF_PI);
    vel.y=sqrt(Settings.celestialPull*distance)*sin(phase+HALF_PI);
    pos.x=orbitStar.pos.x+distance*cos(phase);
    pos.y=orbitStar.pos.y+distance*sin(phase);
    spin=random(-1, 1);
    orbitNumber=number;
    surface=createImage((int)radius, (int)radius, ARGB);
    terrain=new Terrain[surface.width*surface.height];
    if (height<width)
      mapRes=floor(height/(surface.height+20));
    else
      mapRes=floor(width/(surface.width+20));
    createMap();
  }

  void orbitalMovement() {
    grav=new PVector();
    grav.x=-(pos.x-orbitStar.pos.x);
    grav.y=-(pos.y-orbitStar.pos.y);
    grav.normalize();
    grav.mult(Settings.celestialPull);
    vel.add(grav);
  }

  void pullObjects() { //Gravitational pull
  float currDist;
    for (Ship s : ships) { 
      if (!s.warp) {
        currDist=getDistTo(s);
        if (currDist<gravWellRadius&&currDist>radius) {
          s.vel.add(new PVector(pos.x-s.pos.x, pos.y-s.pos.y).normalize().mult(gravPull*(1-pow(currDist/gravWellRadius,2))));
        }
      }
    }
  }

  void createMap() { //Creates a surface map for the planet
    surface.loadPixels();
    surfaceScreen=new Map(new PVector(surface.height*mapRes, surface.width*mapRes), this);
    float seaLevel=random(40, 180);
    float noiseOffset=orbitNumber*10000;
    float prevT=seaLevel;
    for (int y=0; y<surface.height; y++)
    { 
      Terrain t;
      for (int x=0; x<surface.width; x++)
      { 
        prevT=noise(float(x)/100+noiseOffset, float(y)/100+noiseOffset)*seaLevel;
        totalHeight+=prevT;
        t=terrain[x+y*surface.height]=(new Terrain(x, y, prevT, this, x+y*surface.height));
        surface.pixels[y*surface.height+x]=color(round(t.totalOre));
        avgHeight=(avgHeight+t.totalOre)/2;
        if (minHeight>t.totalOre)
          minHeight=t.totalOre;
        if (maxHeight<t.totalOre)
          maxHeight=t.totalOre;
      }
    }
    createSurfaceImagery();
  }

  void createSurfaceImagery() {
    for (Terrain t : terrain)
    { 
      if (t.totalOre>minHeight+(avgHeight-minHeight)*waterLevel)
      {
        t.fill=color(map(t.totalOre, minHeight, maxHeight, 255, 0), map(t.totalOre, minHeight, maxHeight, 0, 255), 0);
      } else
      {
        t.water=true;
        t.waterColour=map(t.totalOre, minHeight*0.5, (minHeight+(avgHeight-minHeight)*waterLevel)*1.3, 0, 255);
        t.fill=color(0, 0, t.waterColour);
        t.depth=map(t.totalOre, minHeight, (minHeight+(avgHeight-minHeight)*waterLevel), 1, 0);
        surface.pixels[t.y*surface.height+t.x]=t.fill;
      }
    }
    surface.updatePixels();
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
  }

  void updateSurfaceImagery() {
    surface.loadPixels();
    for (Terrain t : terrain) 
      if (t.water) surface.pixels[t.y*surface.height+t.x]=t.fill;
      else surface.pixels[t.y*surface.height+t.x]=color(t.totalOre);
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
    surface.updatePixels();
  }

  void updateMapInfo() { //A fairly expensive updater for map info
    totalHeight=0;
    minHeight=99999;
    maxHeight=-99999;
    terrainUpdateQueue=new IntDict();
    Terrain t;
    for (int y=0; y<surface.height; y++)
    { 
      for (int x=0; x<surface.width; x++)
      { 
        t=terrain[x+y*surface.height];
        totalHeight+=t.totalOre;
        avgHeight=(avgHeight+t.totalOre)/2;
        if (minHeight>t.totalOre)
          minHeight=t.totalOre;
        if (maxHeight<t.totalOre)
          maxHeight=t.totalOre;
        if (ceil(t.lava+t.volcanoTime)>0) terrainUpdateQueue.set(""+(x+y*surface.height), ceil(t.lava+t.volcanoTime));
        else t.removeLavaRemnants();
      }
    }
    terrainUpdateQueue.sortValuesReverse();
    String[] trueQueue=terrainUpdateQueue.keyArray();
    for (int i=0; i<trueQueue.length; i++) terrain[int(trueQueue[i])].propagateLava();
  }

  Terrain pickTile() {
    int xOffset=round(width-surfaceScreen.dimension.x)/2;
    int yOffset=round(height-surfaceScreen.dimension.y)/2;
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

  void update() {
    orbitalMovement();
    pullObjects();
    super.update();
    if (frameCount%5==0) updateMapInfo();
  }

  void softDraw(PGraphics rr) {
    rr.pushMatrix();
    rr.translate(0, 0, -1);
    rr.stroke(255, 125+75*cos(gameTime));
    rr.noFill();
    rr.ellipse(orbitStar.pos.x, orbitStar.pos.y, distance*2, distance*2);
    rr.line(pos.x, pos.y, orbitStar.pos.x, orbitStar.pos.y);
    rr.popMatrix();

    rr.pushMatrix();
    rr.translate(0, 0, 1);
    rr.noFill();
    rr.strokeWeight(1);
    rr.ellipse (pos.x, pos.y, diameter, diameter);
    rr.ellipse (pos.x, pos.y, gravWellDiameter, gravWellDiameter);
    rr.popMatrix();
  }

  void draw(PGraphics rr) 
  {
    softDraw(rr);
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate((gameTime)/4*spin);
    rr.image(surface, 0-surface.width/(surface.width/radius), 0-surface.height/(surface.height/radius), surface.width/2, surface.height/2);
    rr.popMatrix();
  }

  void spawn() {
    planets.add(this);
    super.spawn();
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    planets.remove(this);
    super.destroy();
  }
}
