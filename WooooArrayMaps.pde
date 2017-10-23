boolean[] move;
float spill=0;
ArrayList<Star> stars;
ArrayList<Planet> planets;
long seed=1;
float offx=0;
float offy=0;
float zoom=1;
PVector mapScreenShift;
boolean mapScreen;
boolean heightColour;
int tSize=50;
Terrain active;
Ship ship;

PFont pixFont;

void setup()
{

  size(700, 700, P3D);
  pixFont=createFont("Minecraftia-Regular.ttf", 120, true);
  textFont(pixFont, 12);
  stars=new ArrayList<Star>();
  planets=new ArrayList<Planet>();
  move=new boolean[4];
  ship= new Ship();
  stars.add(new Star(0, 0));
  mapScreenShift=new PVector(100, 100);
}

void draw()
{
  background(0);
  if (ship.land!=null)
  {
  } else
  {
  }

  ship.update();
  ship.draw();
  drawStars();
  drawPlanets();
  //stars();
  //camera(pos.x+mouseX-width/2, pos.y+mouseY-height/2, zoom*600.0, pos.x+mouseX-width/2, pos.y+mouseY-height/2, 0.0, 0.0, 1.0, 0.0);
  camera(ship.pos.x, ship.pos.y, zoom*600, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);
  if (mapScreen) {
    camera(ship.pos.x, ship.pos.y, (height/2.0) / tan(PI*30.0 / 180.0)*zoom, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);
    pushMatrix();
    translate(ship.pos.x-width/2*zoom+mapScreenShift.x*zoom, ship.pos.y-height/2*zoom+mapScreenShift.y*zoom, 2);
    scale(zoom);
    rectMode(CENTER);
    for (Terrain t : ship.land.terrain)
    {
      t.draw();
      if (t.checkHover())
      {
        fill(255);
        text("Current: "+t.elevation, 50, -40);
        text("Deepness: "+t.depth, 250, -40);
        text("Index: "+t.index, 50,-20);
      }
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
    text("Total Height: "+ship.land.totalHeight, 250,-20);
    //image(ship.land.map, -mapScreenShift.x+(width-ship.land.map.width)/4, -mapScreenShift.y+(height-ship.land.map.height)/4);
    popMatrix();
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

void mouseReleased()
{
  if (mouseButton==RIGHT)
  {
    if (mapScreen)
    {
      heightColour=!heightColour;
    } else
    {
      ship.warp=!ship.warp;
    }
  }
  if (mouseButton==LEFT)
  {
    if (mapScreen) 
    {
      boolean hovered=false;
      for (Terrain t : ship.land.terrain)
      {
        if (t.checkHover())
        {
          t.build();
          t.volcanize();
          hovered=true;
        }
      }
      if (!hovered)
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

void keyReleased() {
  if (!mapScreen) {
    if ((key == 'w')||(keyCode==UP)||(key=='W'))  move[0] = false;
    if ((key == 'a')||(keyCode==LEFT)||(key=='A'))  move[1] = false;
    if ((key == 's')||(keyCode==DOWN)||(key=='S')) move[2] = false;
    if ((key == 'd')||(keyCode==RIGHT)||(key=='D'))  move[3] = false;
  }
}

void keyPressed()
{ 
  if (!mapScreen) {
    if ((key == 'w')||(keyCode==UP)||(key=='W'))  move[0] = true;
    if ((key == 'a')||(keyCode==LEFT)||(key=='A'))  move[1] = true;
    if ((key == 's')||(keyCode==DOWN)||(key=='S'))  move[2] = true;
    if ((key == 'd')||(keyCode==RIGHT)||(key=='D'))  move[3] = true;
  }
}

void drawStars() {
  for (Star s : stars) {
    s.draw();
  }
}
void drawPlanets() {
  for (Planet p : planets) {
    p.update();
    p.draw();
  }
}