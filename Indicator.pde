class Indicator{
  Object parent;
  PVector screenPos;
  PVector size;

  Indicator(float x, float y, float sX, float sY, Object _parent){
    screenPos = new PVector(x,y);
    size = new PVector(sX,sY);
    parent=_parent;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(PGraphics rr){
    noFill();
    stroke(120+120*sin((float)frameCount/3),80+80*sin((float)frameCount/3),0);
    rect(screenPos.x, screenPos.y, size.x, size.y);
  }
}

//========================================================================================
//========================================================================================
//========================================================================================

class VelocityIndicator extends Indicator{
  
  Ship parent;            //This indicator belongs to a ship [player]
  PVector relVel;         //Relative velocity to some object
  PVector relDir;         //Direction of the speedometer's arrows
  PVector leftArrowDir;   //Used in arrow lines' angle calculation
  PVector rightArrowDir;  //
  float speed=0;          //How many speed arrows are present
  float angle=0;          //General angle of the arrow
  float arrowOffset=6;      //Offsets the indicator by the equivalent amount of arrows.


//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  VelocityIndicator(float x, float y, float sX, float sY, Ship _parent){
    super(x,y,sX,sY,_parent);
    parent=_parent;
    relVel=new PVector(0,0);
    relDir=new PVector(0,0);
    leftArrowDir=new PVector(0,0);
    rightArrowDir=new PVector(0,0);
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                   General functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  PVector calculateRelativeVelocity(Object _relativeTo){
    relVel.x=parent.vel.x-_relativeTo.vel.x;
    relVel.y=parent.vel.y-_relativeTo.vel.y;
    return relVel.copy();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(Object _relativeTo, color _velocityColour, PGraphics rr){
    rr.stroke(_velocityColour);
    rr.strokeWeight(1);
    calculateRelativeVelocity(_relativeTo);
    speed=relVel.mag();
    relDir=relVel.normalize();
    angle=relDir.heading()+HALF_PI;
    leftArrowDir.x=relDir.x+5*sin(angle-2.4434609528);  //2.4434609528 rad is 140 degrees.
    leftArrowDir.y=relDir.y-5*cos(angle-2.4434609528);  //
    rightArrowDir.x=relDir.x+5*sin(angle+2.4434609528); //
    rightArrowDir.y=relDir.y-5*cos(angle+2.4434609528); //
    relDir.mult(5);
    int i;
    float offset;
    for (i=0; i<speed/Settings.speedArrowsDivider; i++){
      offset=i+arrowOffset*(1-parent.zoom/Settings.maxZoom);

      rr.line(screenPos.x+relDir.x*offset, 
              screenPos.y+relDir.y*offset, 
              screenPos.x+relDir.x*offset+leftArrowDir.x, 
              screenPos.y+relDir.y*offset+leftArrowDir.y);

      rr.line(screenPos.x+relDir.x*offset, 
              screenPos.y+relDir.y*offset, 
              screenPos.x+relDir.x*offset+rightArrowDir.x, 
              screenPos.y+relDir.y*offset+rightArrowDir.y);
    }

    rr.stroke(red(_velocityColour),green(_velocityColour),blue(_velocityColour),alpha(_velocityColour)*(speed-i)*255.0);
    offset=i+arrowOffset;
    i++;

    rr.line(screenPos.x+relDir.x*offset, 
      screenPos.y+relDir.y*offset, 
      screenPos.x+relDir.x*offset+leftArrowDir.x, 
      screenPos.y+relDir.y*offset+leftArrowDir.y);

    rr.line(screenPos.x+relDir.x*offset, 
      screenPos.y+relDir.y*offset, 
      screenPos.x+relDir.x*offset+rightArrowDir.x, 
      screenPos.y+relDir.y*offset+rightArrowDir.y);

    rr.stroke(100,100,255,190);
    rr.line(screenPos.x+140*cos(parent.dir),                //0.1745329252 is 10 degrees.
            screenPos.y+140*sin(parent.dir),                //
            screenPos.x+125*cos(parent.dir-0.1745329252),   //
            screenPos.y+125*sin(parent.dir-0.1745329252));  //
    
    rr.line(screenPos.x+140*cos(parent.dir),                //
            screenPos.y+140*sin(parent.dir),                //
            screenPos.x+125*cos(parent.dir+0.1745329252),   //
            screenPos.y+125*sin(parent.dir+0.1745329252));  //
  }
}

//========================================================================================
//========================================================================================
//========================================================================================

class HeatIndicator extends Indicator{
  
  Ship parent;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  HeatIndicator(float x, float y, float sX, float sY, Ship _parent){
    super(x,y,sX,sY,_parent);
    parent=_parent;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(PGraphics rr, PVector _pos) {
    if (!parent.displayPlanetMap) {
      float startOffset=150;
      float lineArcWidth=0.1;
      float lineStep=4;
      float hullTemp;
      int maxLines=0;
      rr.strokeWeight(1);
      rr.stroke(0, 0, 200);

      //rr.line(_pos.x, _pos.y, _pos.x+100*cos(parent.dir), _pos.y+100*sin(parent.dir));

      for (int i=0; i<parent.heatArray.length; i++) {
        hullTemp=parent.heatArray[i]/Settings.hullPieceMass;
        if (hullTemp>Settings.hullMeltingPoint) 
          { 
            maxLines=Settings.hullMeltingPoint/100;
            float pX=parent.sprt.width*cos(i*QUARTER_PI/4)*0.08;
            float pY=parent.sprt.height*sin(i*QUARTER_PI/4)*0.08;
            particles.add(new Particle(sprites.Debris[round(random(0, sprites.debrisImages-1))], 
              new PVector(
                parent.pos.x+random(-6,6)+parent.vel.x-pX*cos(parent.dir+PI)
                -pY*sin(parent.dir),
                parent.pos.y+random(-6,6)+parent.vel.y-pX*sin(parent.dir+PI)
                +pY*cos(parent.dir)),
              new PVector(parent.vel.x, parent.vel.y), random(TWO_PI), color(255), 0.2, random(-1, -2), -0.0001, random(-0.5, 0.5), 255, true));
            parent.HP-=0.001;
          }
        else maxLines=round(hullTemp/100);
        for (int j=0; j<maxLines; j++)
        {
          if (j==21) rr.strokeWeight=3;
          else rr.strokeWeight=1;
          rr.stroke (map(j, 6, 22, 100, 255), map(j, 10, 20, 255, 50), 0, 140+cos(gameTime)*50);
          rr.line(_pos.x+(startOffset+lineStep*j)*cos(i*QUARTER_PI/4+lineArcWidth+parent.dir), _pos.y+(startOffset+lineStep*j)*sin(i*QUARTER_PI/4+lineArcWidth+parent.dir), _pos.x+(startOffset+lineStep*j)*cos(i*QUARTER_PI/4-lineArcWidth+parent.dir), _pos.y+(startOffset+lineStep*j)*sin(i*QUARTER_PI/4-lineArcWidth+parent.dir));
        }
      }
    }
  }

}
