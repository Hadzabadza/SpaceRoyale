//TODO: Fix mapScreen, move all corresponding vars to ship object //<>// //<>//
//TODO: Create a (level/sector/galactic map/etc) superclass, replicate structure of "main" roguelike, more OOP
//TODO: SHIP: Improve targeting!
//TODO: MISSILE: Improve targeting!!!!
//TODO: OSC: Find the name of the connected device and add to bundle logs.
//TODO: OSC: Fix controller unresponsiveness after reinit
//TODO: Fix fetchkvetch
//TODO: improve particle systems, maybe put into a manager class

import oscP5.*;
import netP5.*;

void setup() {
  size(1300, 650, P2D);
  surface.setLocation((displayWidth-1300)/2, (displayHeight-650)/2);
  pixFont=createFont("Minecraftia-Regular.ttf", 120, true);
  textFont(pixFont, 12);
  frameRate(Settings.FPS);
  loadImages();
  init();
}

void init() {
  gameState=0;
  frameCount=0;
  stars=new ArrayList<Star>();
  planets=new ArrayList<Planet>();
  asteroids=new ArrayList<Asteroid>();
  bullets=new ArrayList<Bullet>();
  missiles=new ArrayList<Missile>();
  ships=new Ship[Settings.ships];
  particles=new ArrayList<Particle>();
  spareParticles=new ArrayList<Particle>();
  destroyees=new ArrayList<Object>();
  newSpawns=new ArrayList<Object>();
  objects=new ArrayList<Object>();
  screen= new PGraphics[Settings.ships];
  view= new ArrayList<View>();
  stars.add(new Star(0, 0));
  
  for (int i=0; i<Settings.ships; i++) {
    float startDir=TWO_PI/Settings.ships*i;
    PVector startPos=new PVector((stars.get(0).radius+Settings.shipSize*2.5)*cos(startDir), (stars.get(0).radius+Settings.shipSize*2.5)*sin(startDir));
    screen[i]=createGraphics(width/Settings.ships, height, P3D);
    switch (i) {
    case 0: 
      {
        ships[i]=new Ship(startPos, startDir, color(255, 0, 0));
        break;
      }
    case 1: 
      {
        ships[i]=new Ship(startPos, startDir, color(0, 255, 0));
        break;
      }
    case 2: 
      {
        ships[i]=new Ship(startPos, startDir, color(0, 0, 255));
        break;
      }
    case 3: 
      {
        ships[i]=new Ship(startPos, startDir, color(0, 255, 255));
        break;
      }
    case 4: 
      {
        ships[i]=new Ship(startPos, startDir, color(255, 0, 255));
        break;
      }
    case 5: 
      {
        ships[i]=new Ship(startPos, startDir, color(255, 255, 0));
        break;
      }
    case 6: 
      {
        ships[i]=new Ship(startPos, startDir, color(100, 100, 0));
        break;
      }
    case 7: 
      {
        ships[i]=new Ship(startPos, startDir, color(100));
        break;
      }
    }
  }
  mapScreenShift=new PVector(100, 100);
  cursor=new PVector(0.5, 0.5);
  if (osc!=null) {
    osc.exit();
    osc=null; 
    System.gc();
  }
  osc=new OscHub(Settings.ships);
  println("Setting up..................");
}

void draw() {
  if (Settings.DEBUG) println("...................................................NEWFRAME..................................................................");
  if (gameState==0) {
    background(0, 255*(frameCount-1)/Settings.ships, 0);
    if (frameCount<=Settings.ships) osc.dock[frameCount-1]=osc.dock[frameCount-1].initializeDock();
    else gameState=1;
  }
  if (gameState==1) {
    objectUpdates();
    background(0);
    osc.update();
    int screenSize=width/screen.length;
    int halfScreen=screenSize/2;
    for (int i=0; i<screen.length; i++)
    {
      screen[i].beginDraw();
      float cameraZ=((screen[i].height/2.0) / tan(PI*60.0/360.0));
      screen[i].perspective(PI/3.0, float(screen[i].width)/float(screen[i].height), cameraZ/100.0, cameraZ*100.0) ;
      screen[i].background(Settings.backgroundColor);
      if (ships[i].warp) screen[i].camera(ships[i].pos.x+random(-ships[i].warpSpeed/2, ships[i].warpSpeed/2), ships[i].pos.y+random(-ships[i].warpSpeed/2, ships[i].warpSpeed/2), ships[i].zoom*600, ships[i].pos.x+random(-ships[i].warpSpeed, ships[i].warpSpeed), ships[i].pos.y+random(-ships[i].warpSpeed, ships[i].warpSpeed), 0.0, 0.0, 1.0, 0.0);
      else screen[i].camera(ships[i].pos.x, ships[i].pos.y, ships[i].zoom*600, ships[i].pos.x, ships[i].pos.y, 0.0, 0.0, 1.0, 0.0);
      for (Object o : objects) {
        o.draw(screen[i]);
      }
      ships[i].drawTarget(screen[i]);
      ships[i].drawAim(screen[i]);
      screen[i].endDraw();
      image(screen[i], screenSize*i, 0);
    }
    stroke (255);
    strokeWeight(1);
    for (int i=0; i<screen.length; i++)
    {
      fill(60+195*(1-ships[i].HP), 60+195*ships[i].HP, 0);
      rect(screenSize*i+halfScreen-50, 10, 100*ships[i].HP, 10);
      fill(100, 150, 255);
      rect(screenSize*i+halfScreen-50, 25, ships[i].warpSpeed*2, 10);
      noFill();
      rect(screenSize*i+halfScreen-50, 10, 100, 10);
      rect(screenSize*i+halfScreen-50, 25, 100, 10);
    }
    int xPos=1;
    for (View v:view) {
      v.pos.x=xPos;
      v.pos.y=height-1-v.dimension.y;
      v.draw(this.g);
      xPos+=v.dimension.x+1;
    }
    strokeWeight(3);
    stroke(255);
    for (int i=1; i<screen.length; i++) line (screenSize*i, 0, screenSize*i, height);

    /*if (mapScreen) {
     camera(ship.pos.x, ship.pos.y, (height/2.0) / tan(PI*30.0 / 180.0)*zoom, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);
     pushMatrix();
     translate(ship.pos.x-width/2*zoom+mapScreenShift.x*zoom, ship.pos.y-height/2*zoom+mapScreenShift.y*zoom, 2);
     scale(zoom);
     rectMode(CENTER);
     if (ship.land!=null) {
     for (Terrain t : ship.land.terrain)
     {
     t.draw();
     }
     Terrain selected=ship.land.pickTile();
     if (selected!=null)
     {
     fill(255);
     text("Current: "+selected.elevation, 50, -40);
     text("Deepness: "+selected.depth, 250, -40);
     text("Index: "+selected.index, 50, -20);
     }
     fill(255);
     textAlign(CENTER);
     text("Avg: "+ship.land.avgHeight, 50, -60);
     text("Max: "+ship.land.maxHeight, 250, -60);
     text("Min: "+ship.land.minHeight, 450, -60);
     if (heightColour)
     text("Height Colouring: ON", 450, -40);
     else
     text("Height Colouring: OFF", 450, -40);
     text("Total Height: "+ship.land.totalHeight, 250, -20);
     //image(ship.land.map, -mapScreenShift.x+(width-ship.land.map.width)/4, -mapScreenShift.y+(height-ship.land.map.height)/4);
     popMatrix();
     } else
     {
     mapScreen=false;
     }
     }*/
  }
}


void objectUpdates() {
  for (Object o : objects) {
    o.update();
  }
  for (int i=destroyees.size()-1; i>=0; i--) {
    destroyees.get(i).destroy();
    destroyees.remove(i);
  }
  for (int i=newSpawns.size()-1; i>=0; i--) {
    newSpawns.get(i).spawn();
    newSpawns.remove(i);
  }
}

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

void exit() {
  println("quitting");
  osc.exit();
  super.exit();
}
