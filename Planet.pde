class Planet extends Object {
  
  //Orbital parameters
  Star orbitStar;               //Orbited star.
  float starPull;               //Gravitational pull of the parent star.
  float distance;               //Distance from the star.
  int gravWellRadius;           //Radius of the planetary gravity well.
  int gravWellDiameter;         //Diameter of the above.
  float gravPull;               //Gravitational pull of the planet.
  PVector grav;                 //Temporary vector for calculation of the parent star's gravity forces.
  int orbitNumber;              //Number of planet's orbit, also used as its ID.

  //Vars for calculating planetary shade
  PVector[] shadePoints;        //0 - Left, 1 - right, 2 - tip. Tip lies on the furthest point of stellar grav radius.
  float[] shadeFunctions;       //0 - Left shade border function, 1 - right, 2 - function from the tip of the ship to the tip of the shade.
  float dirFromStar;            //Direction from the origin towards this planet, imagine this being the light beam's direction.
  
  //Surface parameters
  PImage surface;               //Surface image that represents the planet on the solar system map.
  Map surfaceScreen;            //The actual class for representing the tiles on a screen.
  int terrainSize;              //How many terrain tiles are along an axis. Both axes are equal, as maps are squares.
  int surfWidthCoeff;           //How many pixels on the surface image are taken by a tile.
  int surfHeightCoeff;          //
  float density;                //Bloats the planet's surface image inversely proportional to this value. TODO: Use in resource generation.
  float mass;                   //Planetary mass.
  float avgHeight=122;          //Average tile height.
  float minHeight=255;          //Lowest point on the map.
  float maxHeight=0;            //Highest point on the map.
  float totalHeight=0;          //Total landmass of the planet. 
  float totalLava=0;            //Total lava level of the planet, TODO: replace with liquids.
  float waterLevel=0;           //Eye-candy water, to be removed. TODO: replace with actual liquids.
  int mapRes;                   //This is the multiplier for the map's pixel representation.
  IntDict terrainUpdateQueue;   //Unused due to being computationally expensive, used to even out the distribution of lava.
  float[] maxRes;               //Maximum amount ot resource on planet.
  Terrain [] terrain;           //Array of terrain tiles.
  Terrain selected;             //Currently selected tile. TODO: make this multiplayer-friendly.
  float ambientTemp;            //Planet's ambient temperature. All tiles start with this, heats the ship up to this value if landed.

  //Update queue
  float[] lavaChange;           //
  float[] liquidPressureChange; //

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Planet(Star s, float mas, float dens, float distS, int number) {     //
    super(new PVector(), new PVector(), 0, sqrt(mas)/dens);            //
    orbitStar=s;                                                       //
    mass=mas;                                                          //
    density=dens;                                                      //
    distance = distS+orbitStar.radius;                                 //
    starPull=s.gravPull/pow(distance, 2);                              //
    gravPull=mass;                                                     //
    gravWellRadius=round(radius*Settings.gravityWellRadiusMultiplier); //
    gravWellDiameter=gravWellRadius*2;                                 //
    waterLevel=random(0.1, 0.9);                                       //
    float phase=random(0, TWO_PI);                                     //

    if (random(0, 1)<0.98) {                            //Small chance that the planet will have a retrograde orbit.
      vel.x=sqrt(starPull*distance)*cos(phase+HALF_PI); //
      vel.y=sqrt(starPull*distance)*sin(phase+HALF_PI); //
    } else                                              //
    {                                                   //
      vel.x=sqrt(starPull*distance)*cos(phase-HALF_PI); //
      vel.y=sqrt(starPull*distance)*sin(phase-HALF_PI); //
    }

    pos.x=orbitStar.pos.x+distance*cos(phase);               //
    pos.y=orbitStar.pos.y+distance*sin(phase);               //
    spin=random(-1, 1)*TWO_PI/Settings.FPS/60;               //Speed of planet's rotation, in revelations per minute.
    orbitNumber=number;                                      //
    terrainSize=round(radius*density)/2;                     //
    surface=createImage(terrainSize*4, terrainSize*4, ARGB); //
    surfWidthCoeff=surface.width/terrainSize;                //
    surfHeightCoeff=surface.height/terrainSize;              //
    ambientTemp=s.mass/(2*PI*distance)*radius;               //This is how much energy a planet gets and has to give away to stabilise temperature.
    ambientTemp*=PI*diameter/mass;                           //This is its actual temperature.
    terrain=new Terrain[terrainSize*terrainSize];            //
    lavaChange=new float[terrainSize*terrainSize];           //
    liquidPressureChange=new float[terrainSize*terrainSize]; //
    if (height<width)                                        //
      mapRes=floor(height/(terrainSize+20));                 //
    else                                                     //
      mapRes=floor(width/(terrainSize+20));                  //
    createMap();                                             //
    shadePoints=new PVector[4];                              //
    shadeFunctions=new float[4];                             //
    for (int i=0; i<3; i++){                                 //
      shadePoints[i]=new PVector(0,0);                       //
      shadeFunctions[i]=0;                                   //
    }                                                        //
    maxRes=new float[resourceNames.length*3];                //
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  boolean checkCollision(Object with, float radBonus) {
    if (dist(pos.x, pos.y, with.pos.x, with.pos.y)<=with.radius+radius+radBonus) return true;
    else return false;
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

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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
          if(s.land==this)
           {
            float currDir=getDirTo(s);
            s.vel=vel.copy();
            s.pos.x=pos.x+currDist*cos(currDir+spin);
            s.pos.y=pos.y+currDist*sin(currDir+spin);
            for (int i=0; i<s.heatArray.length; i++) 
            { 
              float heatTransfer=ambientTemp*Settings.hullPieceMass;
              if (heatTransfer>s.heatArray[i]) s.heatArray[i]+=(heatTransfer-s.heatArray[i])*0.01;
               //println(ambientTemp*Settings.hullPieceMass/s.heatArray[i]);
            }
          } 
          else s.vel.add(new PVector(pos.x-s.pos.x, pos.y-s.pos.y).normalize().mult(gravPull/pow(currDist, 2)));
        }
      }
    }
    for (Bullet b : bullets) { 
      currDist=getDistTo(b);
      if (currDist<gravWellRadius) b.vel.add(new PVector(pos.x-b.pos.x, pos.y-b.pos.y).normalize().mult(gravPull/pow(currDist, 2)));
    }
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
    totalLava=0;
    avgHeight=0;
    terrainUpdateQueue=new IntDict();
    for (int i=0; i<maxRes.length; i++) maxRes[i]=0;
    Terrain t;
    for (int y=0; y<terrainSize; y++)
    { 
      for (int x=0; x<terrainSize; x++)
      { 
        t=terrain[x+y*terrainSize];
        totalHeight+=t.totalOre;
        totalLava+=t.lava;
        avgHeight+=t.totalOre;
        if (minHeight>t.totalOre) minHeight=t.totalOre;
        if (maxHeight<t.totalOre) {
          maxHeight=t.totalOre;
        }
        for (int i=0; i<maxRes.length; i++) if (t.resources[i]>maxRes[i]) maxRes[i]=t.resources[i];
        if (ceil(t.lava+t.volcanoTime)>0) t.propagateLava();//terrainUpdateQueue.set(""+(x+y*terrainSize), ceil(t.lava+t.volcanoTime));
        //else t.removeLavaRemnants();
      }
    }
    for (int i=0; i<terrain.length; i++){
      terrain[i].lava+=lavaChange[i];
      terrain[i].liquidPressure=liquidPressureChange[i];
      lavaChange[i]=0;
      liquidPressureChange[i]=0;
    }
    avgHeight/=terrainSize*terrainSize;
    /*terrainUpdateQueue.sortValuesReverse();
    String[] trueQueue=terrainUpdateQueue.keyArray();
    for (int i=0; i<trueQueue.length; i++) terrain[int(trueQueue[i])].propagateLava();*/
  }

  void update() {
    orbitalMovement();
    pullObjects();
    dir=(dir+spin)%TWO_PI;
    super.update();
    if (frameCount%1==0) updateGlobalInfo();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

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
