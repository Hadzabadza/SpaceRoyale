class Map {
  Planet p;
  PVector dimension;
  PVector screeenPos;
  PGraphics screen;
  int id;
  boolean active;

  Map(PVector _dimension, Planet _p) {
    dimension=new PVector(_dimension.x, _dimension.y);
    //screenPos=new PVector(_screenPos.x, _screenPos.y);
    id=_p.orbitNumber;
    p=_p;
    screen=createGraphics(floor(dimension.x), floor(dimension.y), P3D);
    active=false;
  }

  void draw(PGraphics rr, Ship ship, PVector pos) {    
    screen.beginDraw();
    screen.background(30+15*cos(gameTime), 45+23*cos(gameTime), 65+33*cos(gameTime));
    // camera(ship.pos.x, ship.pos.y, (height/2.0) / tan(PI*30.0 / 180.0)*zoom, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);
    // pushMatrix();
    // translate(ship.pos.x-width/2*zoom+mapScreenShift.x*zoom, ship.pos.y-height/2*zoom+mapScreenShift.y*zoom, 2);
    // scale(zoom);
    screen.rectMode(CENTER);
    for (Terrain t : p.terrain)
    {
      t.draw(screen);
    }
    screen.endDraw();
    Terrain selected=ship.land.pickTile();
    if (selected!=null)
    {
      rr.fill(255);
      rr.text("Current: "+selected.elevation, 50, -40);
      rr.text("Depth: "+selected.depth, 250, -40);
      rr.text("Index: "+selected.index, 50, -20);
    }
    rr.fill(255);
    rr.textAlign(CENTER);
    rr.text("Avg: "+ship.land.avgHeight, 50, -60);
    rr.text("Max: "+ship.land.maxHeight, 250, -60);
    rr.text("Min: "+ship.land.minHeight, 450, -60);
    if (heightColour)
      rr.text("Height Colouring: ON", 450, -40);
    else
      rr.text("Height Colouring: OFF", 450, -40);
    rr.text("Total Height: "+ship.land.totalHeight, 250, -20);
    //image(ship.land.map, -mapScreenShift.x+(width-ship.land.map.width)/4, -mapScreenShift.y+(height-ship.land.map.height)/4);
    rr.strokeWeight(1);
    rr.stroke(255);
    rr.noFill();
    rr.image(screen, pos.x, pos.y);
    rr.rect(pos.x-1, pos.y-15, screen.width, screen.height+15);
    rr.fill(66, 100, 180);
    rr.rect(pos.x, pos.y-14, screen.width, 15);
    rr.textAlign(LEFT);
    rr.fill(255);
    rr.text("Planet "+id, pos.x+3, pos.y+6);
  }
}
/*
    if (mapScreen) {
 // camera(ship.pos.x, ship.pos.y, (height/2.0) / tan(PI*30.0 / 180.0)*zoom, ship.pos.x, ship.pos.y, 0.0, 0.0, 1.0, 0.0);
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
 text("Depth: "+selected.depth, 250, -40);
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
