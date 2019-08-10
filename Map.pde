class Map { //Used to display the terrain composition of a planet.
  Planet p;
  PVector dimension;
  PVector screeenPos;
  PGraphics screen;
  int id;
  int trueSize;
  boolean active;
  int xOffset;
  int yOffset;
  int mapRes;
  Terrain[] terrain;
  
  //Map display modes
  boolean heightMap=false;
  boolean resourceMap;
  byte shownResource=3;
  boolean pressureMap;

  Map(PVector _dimension, Planet _p) {
    dimension=new PVector(_dimension.x, _dimension.y);
    xOffset=round(width-dimension.x)/2;
    yOffset=round(width-dimension.y)/2;
    id=_p.orbitNumber;
    p=_p;
    screen=createGraphics(floor(dimension.x), floor(dimension.y), P3D);
    active=false;
    trueSize=p.terrainSize;
    mapRes=p.mapRes;
    terrain=p.terrain;
  }
  
  Terrain pickTile(PVector curs) {
    int yOffset=round(height-dimension.y)/2;
    float halfRes=mapRes/2;
    if (curs.x>xOffset-halfRes&&curs.x<width-xOffset-halfRes&&curs.y>yOffset-halfRes&&curs.y<height-yOffset-halfRes) {
      int x=floor((curs.x-xOffset)/mapRes);
      if (x<0) x=0;
      int y=floor((curs.y-yOffset)/mapRes);
      if (y<0) y=0;
      p.selected=p.terrain[x+y*trueSize];
      return p.terrain[x+y*trueSize];
    } else
    {
      p.selected=null;
      return null;
    }
  }

  void draw(PGraphics rr, Ship ship, PVector pos) {    
    screen.beginDraw();
    screen.background(30+15*cos(gameTime), 45+23*cos(gameTime), 65+33*cos(gameTime));
    screen.rectMode(CENTER);
    for (Terrain t : p.terrain)
    {
      t.draw(this);
    }
    screen.endDraw();
    Terrain selected=pickTile(ship.cursor);
    if (height<width) {
      rr.textAlign(LEFT);
      if (selected!=null)
      {
        rr.fill(255);
        rr.text("Index: "+selected.index, pos.x+dimension.x+40, pos.y+20);
        rr.text("Current height: "+selected.totalOre, pos.x+dimension.x+40, pos.y+40);
        rr.text("Depth: "+selected.depth, pos.x+dimension.x+40, pos.y+60);
        rr.text("Solid "+resourceNames[shownResource]+" at ("+selected.x+","+selected.y+"): "+(selected.resources[shownResource*3]), pos.x+dimension.x+40, pos.y+80);
        rr.text("Liquid "+resourceNames[shownResource]+" at ("+selected.x+","+selected.y+"): "+(selected.resources[shownResource*3+1]), pos.x+dimension.x+40, pos.y+100);
        rr.text("Gaseous "+resourceNames[shownResource]+" at ("+selected.x+","+selected.y+"): "+(selected.resources[shownResource*3+2]), pos.x+dimension.x+40, pos.y+120);
        rr.text("Lava: "+selected.lava, pos.x+dimension.x+40, pos.y+140);
        rr.text("Pressure: "+selected.liquidPressure, pos.x+dimension.x+40, pos.y+160);
      }
      rr.fill(255);
      rr.textAlign(LEFT);
      rr.text("Avg: "+ship.land.avgHeight, 50, pos.y+40);
      rr.text("Max: "+ship.land.maxHeight, 50, pos.y+60);
      rr.text("Min: "+ship.land.minHeight, 50, pos.y+80);
      if (heightMap)
        rr.text("Height Colouring: ON", 50, pos.y+20);
      else
        rr.text("Height Colouring: OFF", 50, pos.y+20);
      rr.text("Total Height: "+ship.land.totalHeight, 50, pos.y+100);
      rr.text("Sea level: "+ship.land.waterLevel, 50, pos.y+120);
      rr.text("Max solid "+resourceNames[shownResource]+": "+p.maxRes[shownResource*3], 50, pos.y+140);
      rr.text("Max liquid "+resourceNames[shownResource]+": "+p.maxRes[shownResource*3+1], 50, pos.y+160);
      rr.text("Max gaseous "+resourceNames[shownResource]+": "+p.maxRes[shownResource*3+2], 50, pos.y+180);
      rr.text("Total lava: "+p.totalLava, 50, pos.y+200);
    } else {
      if (selected!=null)
      {
        rr.fill(255);
        rr.text("Current: "+selected.totalOre, pos.x+50, pos.y+40);
        rr.text("Depth: "+selected.depth, pos.x+250, pos.y+40);
        rr.text("Index: "+selected.index, pos.x+50, pos.y+20);
      }
      rr.fill(255);
      rr.textAlign(CENTER);
      rr.text("Avg: "+ship.land.avgHeight, pos.x+50, pos.y+60);
      rr.text("Max: "+ship.land.maxHeight, pos.x+250, pos.y+60);
      rr.text("Min: "+ship.land.minHeight, pos.x+450, pos.y+60);
      if (heightMap)
        rr.text("Height Colouring: ON", pos.x+450, pos.y+40);
      else
        rr.text("Height Colouring: OFF", pos.x+450, pos.y+40);
      rr.text("Total Height: "+ship.land.totalHeight, pos.x+250, pos.y+20);
      rr.text("Sea level: "+ship.land.waterLevel, pos.x+250, pos.y+40);
    }
    rr.strokeWeight(1);
    rr.rectMode(CORNER);
    rr.stroke(255);
    rr.noFill();
    rr.image(screen, pos.x, pos.y);
    rr.rect(pos.x-1, pos.y-15, screen.width, screen.height+15);
    rr.fill(66, 100, 180);
    rr.rect(pos.x, pos.y-14, screen.width, 15);
    rr.textAlign(LEFT);
    rr.textSize(12);
    rr.fill(255);
    rr.text("Planet "+id, pos.x+3, pos.y+6);
  }
}
