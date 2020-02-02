//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                 Universal UI button                                  //
//                           Is being drawn using CENTER mode.                          //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

class Button 
{
  PVector pos;          //Button's position
  PVector dim;          //Button's dimensions
  String name;          //Tooltip displayed on the button
  color c;              //Button's display colour
  color textColor;      //Self-explanatory.
  boolean circular;     //Draws a cirular button if dim.x=dim.y
  boolean horizontal;   //Draws a custom horizontal or vertical button 
  boolean active=true;  //Grays out the button if not
  boolean pressed;      //Determines whether the button is pressed down
  boolean on;           //Used to plug into other functions

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  Button(float xpos, float ypos, float width, float height)
  {
    buttonInit(xpos,ypos,width,height,"",color(255));
  }

  Button(float xpos, float ypos, float width, float height, String _name)
  {
    buttonInit(xpos,ypos,width,height,_name,color(255));
  }
  
  Button(float xpos, float ypos, float width, float height, String _name, color _c)
  {
    buttonInit(xpos,ypos,width,height,_name,_c);
  }
  
  void buttonInit(float x, float y, float w, float h, String _name, color _c){
    pos=new PVector();
    dim=new PVector();
    pos.x=x;
    pos.y=y;
    dim.x=w;
    dim.y=h;
    if (h==w) circular=true;
    else if (h<w) horizontal=true;
    textColor=color(255);
    c=_c;
    name=_name;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  boolean hovered() { //Checks if mouse is on button.
    if (circular) 
      if (dist(mouseX,mouseY,pos.x,pos.y)<=dim.x) return true;
      else return false;
    else if (mouseX > pos.x-dim.x&& mouseX<pos.x+dim.x && mouseY >pos.y-dim.y && mouseY < pos.y+dim.y) return true;
    else return false;
  }

  void toggle(){
    on=!on;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

void draw(PGraphics rr)
  {
    rr.strokeWeight(1);
    rr.textAlign(CENTER);
    color currentColor=c;
    float scaleX; 
    float scaleY;
    float currAlpha;
    if (on) {
      currAlpha=cos(gameTime*2);
      if (circular){
        scaleX=dim.x*0.8;
        scaleY=dim.y*0.8;
      } else {
        scaleX=dim.x-4;
        scaleY=dim.y-4;
      }
    }
    else {
      currAlpha=1;
      scaleX=dim.x;
      scaleY=dim.y;
    }
    if (active) {
      if (hovered()) {
        if (pressed){
          currentColor=color (c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF, 190+30*currAlpha);
          if (circular){
            scaleX=dim.x*0.7;
            scaleY=dim.x*0.7;
          } else {
            scaleX=dim.x-6;
            scaleY=dim.y-6;
          }
        } else currentColor=color (c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF, 170+30*currAlpha);
      }
      else {
        currentColor=color (c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF, 120+30*currAlpha);
      }
    } else currentColor=color(50,120+30*currAlpha);
    if (circular) drawCircular(scaleX,scaleY,currentColor,rr);
    else drawCustom(scaleX,scaleY,currentColor,rr);
    //Button's label
    rr.fill(textColor);
    rr.textSize(dim.y);
    rr.textAlign(CENTER);
    rr.text(name,pos.x,pos.y+dim.y);
  }

  void drawCircular(float scaleX, float scaleY, color currentColor, PGraphics rr){
    rr.ellipseMode(CENTER);

    //Draws the button "slot"
    rr.stroke (150);
    rr.fill(30);
    rr.ellipse(pos.x, pos.y, dim.x, dim.y);
    
    //The button itself
    rr.noStroke();
    rr.fill(currentColor);
    rr.ellipse(pos.x, pos.y, scaleX, scaleY);
  }

  void drawCustom(float scaleX, float scaleY, color currentColor, PGraphics rr)  {
    if (horizontal)
    {
      //Draws the button "slot"
      rr.stroke (255);
      rr.fill(30);
      rr.beginShape();
      rr.vertex(pos.x-dim.x, pos.y-dim.y/2);
      rr.vertex(pos.x-dim.x+dim.y/2, pos.y-dim.y);
      rr.vertex(pos.x+dim.x-dim.y/2, pos.y-dim.y);
      rr.vertex(pos.x+dim.x, pos.y-dim.y/2);
      rr.vertex(pos.x+dim.x, pos.y+dim.y/2);      
      rr.vertex(pos.x+dim.x-dim.y/2, pos.y+dim.y);
      rr.vertex(pos.x-dim.x+dim.y/2, pos.y+dim.y);
      rr.vertex(pos.x-dim.x, pos.y+dim.y/2);
      rr.endShape(CLOSE);

      rr.noStroke();
      rr.fill(currentColor);
      rr.beginShape();
      rr.vertex(pos.x-scaleX, pos.y-scaleY/2);
      rr.vertex(pos.x-scaleX+scaleY/2, pos.y-scaleY);
      rr.vertex(pos.x+scaleX-scaleY/2, pos.y-scaleY);
      rr.vertex(pos.x+scaleX, pos.y-scaleY/2);
      rr.vertex(pos.x+scaleX, pos.y+scaleY/2);      
      rr.vertex(pos.x+scaleX-scaleY/2, pos.y+scaleY);
      rr.vertex(pos.x-scaleX+scaleY/2, pos.y+scaleY);
      rr.vertex(pos.x-scaleX, pos.y+scaleY/2);
      rr.endShape(CLOSE);
    } else drawCircular(scaleX, scaleY, currentColor, rr);
  }

  void drawSelection(){
          /*fill(10);
       rect(pos.x, pos.y, w*1.1, h*2.2);
       arc(pos.x+w*0.55-2, pos.y+1, h*2.2-1, h*2.2-1, -HALF_PI, HALF_PI);
       arc(pos.x-w*0.55+2, pos.y+1, h*2.2-1, h*2.2-1, HALF_PI, PI+HALF_PI);*/
      /*if (hovered())
      {
        float tempW=w+5;
        float tempH=h+5;
        float inc=abs(cos(radians(frameCount)));
        if (inc>0.5)
        {
          tempW*=(0.85+inc*0.3);
          tempH*=(0.85+inc*0.3);
          stroke(255, 405-250*inc);
        } else
        {
          stroke(255);
        }
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW, pos.y+tempH*0.7);
        line(pos.x-tempW*0.6, pos.y-tempH*1.05, pos.x+tempW*0.5, pos.y-tempH*1.05);
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW*0.7, pos.y-tempH*1.2);
        line(pos.x-tempW, pos.y+tempH*1, pos.x+tempW*0.7, pos.y+tempH);
        line(pos.x+tempW*0.6, pos.y-tempH*1.2, pos.x+tempW*0.9, pos.y-tempH*1.2);
        line(pos.x+tempW*0.5, pos.y-tempH, pos.x+tempW*0.6, pos.y-tempH*1.2);
        line(pos.x+tempW*0.9, pos.y-tempH*1.2, pos.x+tempW, pos.y-tempH);
        line(pos.x+tempW, pos.y-tempH, pos.x+tempW, pos.y+tempH*0.8);
        line(pos.x+tempW, pos.y+tempH*0.8, pos.x+tempW*0.9, pos.y+tempH);

        tempW+=4;
        tempH+=4;
        if (inc>0.5)
        {
          //tempW*=(0.85+inc*0.3);
          //tempH*=(0.85+inc*0.3);
          stroke(factionStroke(playerFaction), 405-250*inc);
        } else
        {
          factionStroke(playerFaction);
        }
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW, pos.y+tempH*0.7);
        line(pos.x-tempW*0.6, pos.y-tempH*1.05, pos.x+tempW*0.5, pos.y-tempH*1.05);
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW*0.7, pos.y-tempH*1.2);
        line(pos.x-tempW, pos.y+tempH*1, pos.x+tempW*0.7, pos.y+tempH);
        line(pos.x+tempW*0.6, pos.y-tempH*1.2, pos.x+tempW*0.9, pos.y-tempH*1.2);
        line(pos.x+tempW*0.5, pos.y-tempH, pos.x+tempW*0.6, pos.y-tempH*1.2);
        line(pos.x+tempW*0.9, pos.y-tempH*1.2, pos.x+tempW, pos.y-tempH);
        line(pos.x+tempW, pos.y-tempH, pos.x+tempW, pos.y+tempH*0.8);
        line(pos.x+tempW, pos.y+tempH*0.8, pos.x+tempW*0.9, pos.y+tempH);

        tempW+=4;
        tempH+=4;
        if (inc>0.5)
        {
          //tempW*=(0.85+inc*0.3);
          //tempH*=(0.85+inc*0.3);
          stroke(255, 405-250*inc);
        } else
        {
          stroke(255);
        }
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW, pos.y+tempH*0.7);
        line(pos.x-tempW*0.6, pos.y-tempH*1.05, pos.x+tempW*0.5, pos.y-tempH*1.05);
        line(pos.x-tempW, pos.y-tempH*1.2, pos.x-tempW*0.7, pos.y-tempH*1.2);
        line(pos.x-tempW, pos.y+tempH*1, pos.x+tempW*0.7, pos.y+tempH);
        line(pos.x+tempW*0.6, pos.y-tempH*1.2, pos.x+tempW*0.9, pos.y-tempH*1.2);
        line(pos.x+tempW*0.5, pos.y-tempH, pos.x+tempW*0.6, pos.y-tempH*1.2);
        line(pos.x+tempW*0.9, pos.y-tempH*1.2, pos.x+tempW, pos.y-tempH);
        line(pos.x+tempW, pos.y-tempH, pos.x+tempW, pos.y+tempH*0.8);
        line(pos.x+tempW, pos.y+tempH*0.8, pos.x+tempW*0.9, pos.y+tempH);
      }
      */
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

}
