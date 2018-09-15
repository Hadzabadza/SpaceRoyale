import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress controller;
String[] controllerIP={"192.168.1.162"};
int[] controllerOutPort={8000};
int[] controllerInPort={9000};

ArrayList<Star> stars;
ArrayList<Planet> planets;
ArrayList<Asteroid> asteroids;
ArrayList<Bullet> bullets;
ArrayList<Ship> ships;
Ship ship;
Ship ship1;
ArrayList<Object> destroyees;
ArrayList<Object> newSpawns;
ArrayList<Object> objects;
long seed=1;
float offx=0;
float offy=0;
float zoom=1;
PVector mapScreenShift;
boolean mapScreen;
boolean heightColour;
int tSize=50;
Terrain active;
PVector cursor;
Osc[] osc;
PGraphics leftViewport;
PGraphics rightViewport;


PFont pixFont;

void setup() {
  size(1360, 680, P3D);
  pixFont=createFont("Minecraftia-Regular.ttf", 120, true);
  textFont(pixFont, 12);
  stars=new ArrayList<Star>();
  planets=new ArrayList<Planet>();
  asteroids=new ArrayList<Asteroid>();
  bullets=new ArrayList<Bullet>();
  ships=new ArrayList<Ship>();
  destroyees=new ArrayList<Object>();
  newSpawns=new ArrayList<Object>();
  objects=new ArrayList<Object>();
  ship = new Ship();
  ships.add(ship);
  ship1 = new Ship();
  ship1.c=color(255,255,0);
  stars.add(new Star(0, 0));
  mapScreenShift=new PVector(100, 100);
  cursor=new PVector(0.5, 0.5);
  osc=new Osc[controllerIP.length];
  for (int i=0; i<osc.length; i++)  osc[i]=new Osc(controllerOutPort[i], controllerIP[i], controllerInPort[i]);
  
  leftViewport = createGraphics(width/2, height, P3D);
  rightViewport = createGraphics(width/2, height, P3D);
}

void draw() {
  objectUpdates();
  osc[0].OMUpdate();
  background(50);
  camera(ship.pos.x, ship.pos.y, zoom*600, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);

  for (Object o : objects) {
    o.draw();
  }

  if (mapScreen) {
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
  }
}


void mouseWheel(MouseEvent e) {
  if (e.getCount()>0)
  {
    zoom*=1.01;
  } else
  {
    zoom*=0.99;
  }
}

void mouseReleased() {
  if (mouseButton==RIGHT)
  {
    if (mapScreen)
    {
      heightColour=!heightColour;
    }
  }
  if (mouseButton==LEFT)
  {
    if (mapScreen) 
    {
      Terrain t=ship.land.pickTile();
      if (t!=null)
      {
        t.build();
        t.volcanize();
      }
      if (t==null)
      {
        mapScreen=false;
        active=null;
      }
    } else if (ship.land!=null) {
      mapScreen=true;
      ship.thrust=0;
    }
  }
  if (mouseButton==CENTER)
  {
    zoom=1;
  }
}

void mouseMoved() {
  cursor.x=mouseX;
  cursor.y=mouseY;
}

void objectUpdates() {
  for (Object o : objects) {
    o.update();
  }
  for (int i=destroyees.size()-1; i>=0; i--){
    destroyees.get(i).destroy();
    destroyees.remove(i);
  }
  for (int i=newSpawns.size()-1; i>=0; i--){
    newSpawns.get(i).spawn();
    newSpawns.remove(i);
  }
}

void exit() {
  println("quitting");
  OscMessage exitMessage = new OscMessage("/OM/label35/visible");
  exitMessage.add(1);
  oscP5.send(exitMessage, controller);
  super.exit();
}