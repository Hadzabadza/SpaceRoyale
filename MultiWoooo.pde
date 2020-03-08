import oscP5.*;   //Required libs for TouchOSC controls.  //<>// //<>//
import netP5.*;   //

Slider testSLD;   //
Slider operated;  //

void setup() {
  size(1300, 700, P3D);                                     //Screen size, can't be dynamically adjusted
  surface.setLocation((displayWidth-1300)/2,                //Location of the game window on screen
  (displayHeight-700)/2);                                   //
  
  randomSeed(seed);                                         //DEBUG
  
  pixFont=createFont("Minecraftia-Regular.ttf", 120, true); //The font of the game
  textFont(pixFont, 12);                                    //

  sprites=new IMG();                                        //Loader for all the game's sprites
  sprites.loadImages();                                     //
  
  frameRate(Settings.FPS);                                  //DEBUG

  init();                                                   //
}

void init() {                                //Initialiser. Useful for game restarting
  
  gameState=0;                               //Gamestate reset
  frameCount=0;                              //Framecount restart

  stars=new ArrayList<Star>();               //Resets all tracked object lists
  asteroids=new ArrayList<Asteroid>();       //
  bullets=new ArrayList<Bullet>();           //
  missiles=new ArrayList<Missile>();         //
  ships=new Ship[Settings.ships];            //
  objects=new ArrayList<Object>();           //

  particles=new ArrayList<Particle>();       //Particle buffers
  spareParticles=new ArrayList<Particle>();  //

  destroyees=new ArrayList<Object>();        //Object destruction and construction queues
  newSpawns=new ArrayList<Object>();         //

  screen=new PGraphics[Settings.ships];      //Cameras and displays
  view=new ArrayList<View>();                //

  stars.add(new Star(0, 0));                 //Creates the map

  for (int i=0; i<Settings.ships; i++) {     //Player spawning directions and positions
    float startDir=random(TWO_PI);
    float startDist=random(stars.get(0).gravWellRadius*0.4, stars.get(0).gravWellRadius);
    PVector startPos=new PVector(startDist*cos(startDir), startDist*sin(startDir));
    screen[i]=createGraphics(width/Settings.ships, height, P3D);
    switch (i) {
      case 0: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(000, 255, 000), this.g); break;}
      case 1: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(255, 000, 000), this.g); break;}
      case 2: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(000, 000, 255), this.g); break;}
      case 3: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(000, 255, 255), this.g); break;}
      case 4: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(255, 000, 255), this.g); break;}
      case 5: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(255, 255, 000), this.g); break;}
      case 6: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(100, 100, 000), this.g); break;}
      case 7: {ships[i]=new Ship(startPos, startDir+HALF_PI, color(100, 100, 100), this.g); break;}
    }
    //ships[i].vel.x=stars.get(0).gravPull*120*cos(startDir+HALF_PI);
    //ships[i].vel.y=stars.get(0).gravPull*120*sin(startDir+HALF_PI);
    ships[i].zoom=1;
  }
  //mapScreenShift=new PVector(100, 100);
  //cursor=new PVector(0.5, 0.5);
  if (osc!=null) {
    osc.exit();
    osc=null; 
    System.gc();
  }
  osc=new OscHub(Settings.ships);
  println("Setting up..................");
  float spawnDir=random(TWO_PI);
  //Planet spawnPlanet=stars.get(0).planets.get(0);
  Planet spawnPlanet=stars.get(0).planets[stars.get(0).planets.length-1];
  float spawnDistance=spawnPlanet.gravWellRadius*0.95;
  ships[0].pos.x=spawnPlanet.pos.x+spawnPlanet.radius*cos(spawnDir);
  ships[0].pos.y=spawnPlanet.pos.y+spawnPlanet.radius*sin(spawnDir);
  ships[0].vel.x=spawnPlanet.vel.x;
  ships[0].vel.y=spawnPlanet.vel.y;
  /*ships[0].pos.x=spawnPlanet.pos.x+spawnDistance*cos(spawnDir);
  ships[0].pos.y=spawnPlanet.pos.y+spawnDistance*sin(spawnDir);
  ships[0].vel.x=spawnPlanet.vel.x+sqrt(spawnPlanet.gravPull/spawnDistance)*cos(spawnDir+HALF_PI);
  ships[0].vel.y=spawnPlanet.vel.y+sqrt(spawnPlanet.gravPull/spawnDistance)*sin(spawnDir+HALF_PI);*/
  testSLD=new Slider(width/2,height-30,600,40,resourceNames.length-1,1,"Resource");
}

void draw() {
  rectMode(CORNER);
  gameTime=float(millis())/1000;
  //if (Settings.DEBUG) println("...................................................NEWFRAME..................................................................");
  if (gameState==0) {
    background(0, 255*(frameCount-1)/Settings.ships, 0);
    if (frameCount<=Settings.ships) osc.dock[frameCount-1]=osc.dock[frameCount-1].initializeDock();
    else gameState=1;
  }
  if (gameState==1) { 
    objectUpdates();
    background(backgroundColour);
    osc.update();
    int screenSize=width/screen.length;
    int halfScreen=screenSize/2;
    for (int i=0; i<screen.length; i++)
    {
      screen[i].beginDraw();
      float cameraZ=((screen[i].height/2.0) / tan(PI*60.0/360.0));
      screen[i].perspective(PI/3.0, float(screen[i].width)/float(screen[i].height), cameraZ/100.0, cameraZ*100.0) ;
      screen[i].background(backgroundColour);

      /*screen[i].strokeWeight(3); //ATTEMPT TO MAKE A STAR FIELD
       screen[i].stroke(255);
       for (int x=round(ships[i].pos.x)-screen[i].width/2; x<round(ships[i].pos.x)+screen[i].width/2;x+=10){
       for (int y=round(ships[i].pos.y)-screen[i].height/2; y<round(ships[i].pos.y)+screen[i].height/2;y+=10){
       if (noise(x,y)>0.76) screen[i].point(x,y);
       }
       }*/
      /*int zoomedXBorder=screen[i].height/2*ceil(ships[i].zoom); //ANOTHER ATTEMPT TO MAKE A STAR FIELD
       int zoomedYBorder=screen[i].width/2*ceil(ships[i].zoom);
       for (int backX=-zoomedXBorder; backX<=zoomedXBorder; backX+=IMGStarryBack.width)
       for (int backY=-zoomedYBorder; backY<=zoomedYBorder; backY+=IMGStarryBack.height)
       image(IMGStarryBack, backX+ships[0].pos.x%IMGStarryBack.width, backY+ships[0].pos.y%IMGStarryBack.height, -10);
       */

      //if (ships[i].warp) screen[i].camera(ships[i].pos.x+random(-ships[i].warpSpeed/2, ships[i].warpSpeed/2), ships[i].pos.y+random(-ships[i].warpSpeed/2, ships[i].warpSpeed/2), ships[i].zoom*600, ships[i].pos.x+random(-ships[i].warpSpeed, ships[i].warpSpeed), ships[i].pos.y+random(-ships[i].warpSpeed, ships[i].warpSpeed), 0.0, 0.0, 1.0, 0.0);
      //else 
      screen[i].camera(ships[i].pos.x, ships[i].pos.y, ships[i].zoom*600, ships[i].pos.x, ships[i].pos.y, 0.0, 0.0, 1.0, 0.0);

      for (Object o : objects) { //DRAWS ALL OBJECTS ON SHIP'S SCREEN!!
        if (o.active)
          if (Settings.drawObjectsOnlyInRange) {
            float distToScreenCorner=dist(0, 0, screen[i].height, screen[i].width)*ships[i].zoom/2;
            if (dist(ships[i].pos.x, ships[i].pos.y, o.pos.x, o.pos.y)-o.diameter<distToScreenCorner) o.draw(screen[i]); 
            else o.softDraw(screen[i]);
          } else o.draw(screen[i]);
      }
      if (!ships[i].destroyed) {
        ships[i].drawTarget(screen[i]); //Draws missile target
        ships[i].drawAim(screen[i]); //Draws turret aiming direction
        ships[i].thermometer.draw(this.g, new PVector(screen[i].width/2+screen[i].width*i, screen[i].height/2));
      }
      screen[i].endDraw();
      image(screen[i], screenSize*i, 0);
      if (ships[i].displayPlanetMap&&ships[i].land!=null)
      {
        testSLD.draw(this.g);
        Map mp=ships[i].land.surfaceScreen;
        mp.draw(this.g, ships[i], new PVector((screen[i].width-mp.dimension.x)/2, (screen[i].height-mp.dimension.y)/2));
      }
    }
    stroke (255);
    strokeWeight(1);
    for (int i=0; i<screen.length; i++)
    {
      fill(60+195*(1-ships[i].HP), 60+195*ships[i].HP, 0);
      rect(screenSize*i+halfScreen-50, 10, 100*ships[i].HP, 10);
      fill(100, 150, 255);
      rect(screenSize*i+halfScreen-50, 25, 10+90*ships[i].warpSpeed/Settings.maxWarpSpeed, 10);
      if (Settings.DEBUG) {
        fill(130+50*sin(gameTime), 0, 0);
        text("DEBUG", screenSize*i+20, 20);
        if (ships[i].land!=null)
          fill(0, 130+50*sin(gameTime), 0);
        else
          fill(130+50*sin(gameTime), 0, 0);
        text("LAND", screenSize*i+24, 30);
        text("SPEED: "+ships[0].afterBurner, screenSize*i+24, 40);
      }
      noFill();
      rect(screenSize*i+halfScreen-50, 10, 100, 10);
      rect(screenSize*i+halfScreen-50, 25, 100, 10);
    }
    int xPos=1;
    for (View v : view) {
      v.pos.x=xPos;
      v.pos.y=height-1-v.dimension.y;
      v.draw(this.g);
      xPos+=v.dimension.x+1;
    }
    strokeWeight(3);
    stroke(255);
    for (int i=1; i<screen.length; i++) line (screenSize*i, 0, screenSize*i, height);
  }
  if (operated!=null) operated.changeX();
}


void objectUpdates() {
  for (Object o : objects) o.update();
  for (int i=destroyees.size()-1; i>=0; i--) {
    destroyees.get(i).destroy();
    destroyees.remove(i);
  }
  for (int i=newSpawns.size()-1; i>=0; i--) {
    newSpawns.get(i).spawn();
    newSpawns.remove(i);
  }
}
/* //WASTELANDS
void sprinkleParticles(PImage img, PVector where, int min, int max) {
  int n = round(random(min, max));
  for (int i=0; i<n; i++) particles.add(new Particle(img, where));
  //fetchParticles(n, img, where);
}

void sprinkleParticles(PImage[] imgs, PVector where, int min, int max) {
  int n = round(random(min, max));
  for (int i=0; i<n; i++) particles.add(new Particle(imgs[round(random(0, imgs.length-1))], where));
  //fetchParticles(n, imgs, where);
}

void fetchParticles(int n, PImage img, PVector where) {
  if (spareParts>n) {
    int counter=0;
    int searchFor=spareParts-n;
    for (Particle p : spareParticles) {
      if (counter>=searchFor) {
        particles.add(p);
        p.refresh(img, where);
      } else counter++;
    }
    for (int i=spareParts-1; i>=searchFor; i--) spareParticles.remove(i);
    spareParts=searchFor;
  } else
  {
    for (Particle p : spareParticles) {
      particles.add(p);
      p.refresh(img, where);
    }
    spareParticles.clear();
    for (int i=spareParts-1; i<n; i++) particles.add(new Particle (img, where));
    spareParts=0;
  }
}
void fetchParticles(int n, PImage[] imgs, PVector where) {
  if (spareParts>n) {
    int counter=0;
    int searchFor=spareParts-n;
    for (Particle p : spareParticles) {
      if (counter>=searchFor) {
        particles.add(p);
        p.refresh(imgs[round(random(0, imgs.length-1))], where);
      } else counter++;
    }
    for (int i=spareParts-1; i>=searchFor; i--) spareParticles.remove(i);
    spareParts=searchFor;
  } else
  {
    for (Particle p : spareParticles) {
      particles.add(p);
      p.refresh(imgs[round(random(0, imgs.length-1))], where);
    }
    spareParticles.clear();
    for (int i=spareParts-1; i<n; i++) particles.add(new Particle (imgs[round(random(0, imgs.length-1))], where));
    spareParts=0;
  }
}
*/
void exit() {
  println("quitting");
  osc.exit();
  super.exit();
}
