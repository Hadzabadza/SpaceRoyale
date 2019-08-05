class Planet extends Object {
  
  //Orbital parameters
  Star orbitStar;
  float starPull;
  float distance;
  float spin;
  int gravWellRadius;
  int gravWellDiameter;
  float gravPull;
  PVector grav;
  int orbitNumber;
  PVector[] shadePoints; //0 - Left, 1 - right, 2 - tip (on the furthest point of stellar grav radius)
  float[] shadeFunctions; //0 - Left, 1 - right. Originating from tip
  float dirFromStar;
  
  //Surface parameters
  PImage surface;
  Map surfaceScreen;
  int terrainSize;
  int surfWidthCoeff;
  int surfHeightCoeff;
  float density;
  float mass;
  float avgHeight=122;
  float minHeight=255;
  float maxHeight=0;
  float totalHeight=0;
  float waterLevel=0;
  int mapRes;
  IntDict terrainUpdateQueue;
  Terrain [] terrain;
  Terrain selected;
  Terrain maxTile;
  float surfaceTemp;

  Planet(Star s, float mas, float dens, float distS, int number) {
    super(new PVector(), new PVector(), 0, sqrt(mas)/dens);
    orbitStar=s;
    mass=mas;
    density=dens;
    distance = distS+orbitStar.radius;
    starPull=s.gravPull/pow(distance, 2);
    gravPull=mass;
    gravWellRadius=round(radius*Settings.gravityWellRadiusMultiplier);
    gravWellDiameter=gravWellRadius*2;
    waterLevel=random(0.1, 0.9);
    float phase=random(0, TWO_PI);
    if (random(0, 1)<0.98) { //Small chance that the planet will have a retrograde orbit.
      vel.x=sqrt(starPull*distance)*cos(phase+HALF_PI);
      vel.y=sqrt(starPull*distance)*sin(phase+HALF_PI);
    } else
    {
      vel.x=sqrt(starPull*distance)*cos(phase-HALF_PI);
      vel.y=sqrt(starPull*distance)*sin(phase-HALF_PI);
    }
    pos.x=orbitStar.pos.x+distance*cos(phase);
    pos.y=orbitStar.pos.y+distance*sin(phase);
    spin=random(-1, 1)*TWO_PI/Settings.FPS/60; //Speed of planet's rotation, determined as revelations per minute.
    orbitNumber=number;
    terrainSize=round(radius*density)/2;
    surface=createImage(terrainSize*4, terrainSize*4, ARGB);
    surfWidthCoeff=surface.width/terrainSize;
    surfHeightCoeff=surface.height/terrainSize;
    terrain=new Terrain[terrainSize*terrainSize];
    if (height<width)
      mapRes=floor(height/(terrainSize+20));
    else
      mapRes=floor(width/(terrainSize+20));
    createMap();
    shadePoints=new PVector[4];
    shadeFunctions=new float[4];
    for (int i=0; i<3; i++){
      shadePoints[i]=new PVector(0,0);
      shadeFunctions[i]=0;
    }
    surfaceTemp=s.mass/(2*PI*distance)*radius; //This is how much energy a planet gets and has to give away to stabilise temperature.
    surfaceTemp*=PI*diameter/mass; //This is its actual temperature.
  }

  void orbitalMovement() {
    grav=new PVector(orbitStar.pos.x-pos.x, orbitStar.pos.y-pos.y).normalize().mult(starPull);
    vel.add(grav);
    dirFromStar=orbitStar.getDirTo(this);
    shadePoints[0].x=pos.x+vel.x+radius*cos(dirFromStar-HALF_PI);
    shadePoints[0].y=pos.y+vel.y+radius*sin(dirFromStar-HALF_PI);
    shadePoints[1].x=pos.x+vel.x+radius*cos(dirFromStar+HALF_PI);
    shadePoints[1].y=pos.y+vel.y+radius*sin(dirFromStar+HALF_PI);
    shadePoints[2].x=orbitStar.pos.x+orbitStar.gravWellRadius*cos(dirFromStar);
    shadePoints[2].y=orbitStar.pos.y+orbitStar.gravWellRadius*sin(dirFromStar);
    shadeFunctions[0]=(shadePoints[2].x-shadePoints[0].x)/(shadePoints[2].y-shadePoints[0].y);
    shadeFunctions[1]=(shadePoints[2].x-shadePoints[1].x)/(shadePoints[2].y-shadePoints[1].y);
    shadeFunctions[2]=(shadePoints[0].x-shadePoints[1].x)/(shadePoints[0].y-shadePoints[1].y);
  }

  void pullObjects() { //Gravitational pull and on-surface management of ships.
    float currDist;
    for (Ship s : ships) { 
      if (!s.warp) {
        currDist=getDistTo(s);
        if (currDist<gravWellRadius) {//&&currDist>radius*0.98) {
          if(currDist>radius)
            s.vel.add(new PVector(pos.x-s.pos.x, pos.y-s.pos.y).normalize().mult(gravPull/pow(currDist, 2)));
          else for (int i=0; i<s.heatArray.length; i++) 
          { 
            float heatTransfer=surfaceTemp*Settings.hullPieceMass;
            if (heatTransfer>s.heatArray[i]) s.heatArray[i]+=(heatTransfer-s.heatArray[i])*0.01;
             println(surfaceTemp*Settings.hullPieceMass/s.heatArray[i]);
          }
        }
      }
    }
  }

  void createMap() { //Creates a surface map for the planet
    surface.loadPixels();
    surfaceScreen=new Map(new PVector(terrainSize*mapRes, terrainSize*mapRes), this);
    float seaLevel=random(40, 180);
    noiseDetail(8);
    float noiseOffset=orbitNumber*9321+random(-500, 500);
    float prevT=seaLevel;
    for (int y=0; y<terrainSize; y++)
    { 
      Terrain t;
      for (int x=0; x<terrainSize; x++)
      { 
        prevT=noise(float(x)/100+noiseOffset, float(y)/100+noiseOffset)*seaLevel;
        totalHeight+=prevT;
        t=terrain[x+y*terrainSize]=(new Terrain(x, y, prevT, this, x+y*terrainSize));
        fillPixel(x,y,color(round(t.totalOre)));
        avgHeight+=t.totalOre;
        if (minHeight>t.totalOre)
          minHeight=t.totalOre;
        if (maxHeight<t.totalOre)
          maxHeight=t.totalOre;
          maxTile=t;
      }
    }
    avgHeight/=terrainSize*terrainSize;
    createSurfaceImagery();
  }

  void createSurfaceImagery() { //NEEDS SURFACE.PIXELS LOADED!!
    //println(terrainSize+" "+surface.pixels.length);
    for (Terrain t : terrain)
    { 
      t.depth=t.depthCalculation();
      if (t.depth<=0)
      {
        t.fill=color(t.totalOre);
      } else
      {
        t.water=true;
        t.waterColour=255*(1-t.depth);
        t.fill=color(0, 0, t.waterColour);
      }
      fillPixel(t.x,t.y,t.fill);
    }
    circularizeSurfaceImage();
  }

  void circularizeSurfaceImage(){ //NEEDS SURFACE.PIXELS LOADED!!
    for (int i=0; i<surface.height; i++)
      for (int j=0; j<surface.width; j++)
        if ((j>(surface.width-1)/2+sqrt(sq(surface.width/2)-sq(surface.width/2-i)))||(j<(surface.width+1)/2-sqrt(sq(surface.width/2)-sq(surface.width/2-i))))
          surface.pixels[(int)i*surface.height+(int)j]=color(0, 0);
    surface.updatePixels();
  }

  void fillPixel(int pixX, int pixY, color pixC){
    for (int i=0; i<surfWidthCoeff; i++) 
      for (int j=0; j<surfHeightCoeff; j++) 
        surface.pixels[pixX*surfWidthCoeff+i+pixY*terrainSize*surfHeightCoeff*surfHeightCoeff+j*terrainSize*surfHeightCoeff]=pixC;
          // surface.pixels[pixX*Settings.planetScaler+i+pixY*Settings.planetScaler*terrainSize+j*terrainSize*Settings.planetScaler]=pixC;
    //else surface.pixels[pixX+pixY*terrainSize]=pixC;
  }
  
  boolean checkIfShaded(PVector tp){
    float shipStarFunction=(tp.x-shadePoints[2].x)/(tp.y-shadePoints[2].y);
    //println(orbitNumber+" "+shadeFunctions[0]+" "+shadeFunctions[1]+" "+shipStarFunction+" ");
    if (shadeFunctions[0]<shipStarFunction)
    if (shadeFunctions[1]>shipStarFunction)
    if (dist(orbitStar.pos.x,orbitStar.pos.y,tp.x,tp.y)>=distance) 
    return true;
    return false;
  }

  void updateSurfaceImagery() {
    surface.loadPixels();
    for (Terrain t : terrain) 
      if (t.water) fillPixel(t.x,t.y,t.fill);
      else fillPixel(t.x,t.y,color(t.totalOre));
    circularizeSurfaceImage();
  }


  void updateGlobalInfo() { //A fairly expensive updater for map info
    totalHeight=0;
    minHeight=99999;
    maxHeight=-99999;
    avgHeight=0;
    terrainUpdateQueue=new IntDict();
    Terrain t;
    for (int y=0; y<terrainSize; y++)
    { 
      for (int x=0; x<terrainSize; x++)
      { 
        t=terrain[x+y*terrainSize];
        totalHeight+=t.totalOre;
        avgHeight+=t.totalOre;
        if (minHeight>t.totalOre) minHeight=t.totalOre;
        if (maxHeight<t.totalOre) {
          maxHeight=t.totalOre;
          maxTile=t;
        }
        if (ceil(t.lava+t.volcanoTime)>0) terrainUpdateQueue.set(""+(x+y*terrainSize), ceil(t.lava+t.volcanoTime));
        //else t.removeLavaRemnants();
      }
    }
    avgHeight/=terrainSize*terrainSize;
    terrainUpdateQueue.sortValuesReverse();
    String[] trueQueue=terrainUpdateQueue.keyArray();
    for (int i=0; i<trueQueue.length; i++) terrain[int(trueQueue[i])].propagateLava();
  }

  void update() {
    orbitalMovement();
    pullObjects();
    dir=(dir+spin)%TWO_PI;
    super.update();
    if (frameCount%1==0) updateGlobalInfo();
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
    rr.line(shadePoints[0].x,shadePoints[0].y,shadePoints[2].x,shadePoints[2].y);
    rr.line(shadePoints[1].x,shadePoints[1].y,shadePoints[2].x,shadePoints[2].y);
    rr.popMatrix();
  }

  void draw(PGraphics rr) 
  {
    softDraw(rr);
    rr.pushMatrix();
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.imageMode(CENTER);
    rr.image(surface, 0, 0, surface.width/density, surface.height/density);
    rr.popMatrix();
    rr.imageMode(CORNER);
  }

  void spawn() {
    //orbitStar.planets.add(this);
    super.spawn();
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    //orbitStar.planets.remove(this);
    super.destroy();
  }
}
