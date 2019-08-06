class Slider
  ///////////////////////////////////////////////////////////////////////////
  //Sliders that are used in map generation to allow quick and easy set-up.//
  //Re-used and upgraded code from audio-visual project.                   //
  ///////////////////////////////////////////////////////////////////////////
{
  PVector barPos;
  PVector sliderPos;
  color barColor;
  color sliderColor;
  PVector barSize;
  PVector sliderSize;
  PVector slideArea;
  float power=0.5;
  int steps;
  float minSteps;
  boolean horizontal=true;
  String name;

  Slider(float Bposx, float Bposy, float Bsizex, float Bsizey, int _steps, String _name) {
    sliderInit(Bposx, Bposy, Bsizex, Bsizey, _steps, 1/_steps, _name, color(255,200));
  }

  Slider(float Bposx, float Bposy, float Bsizex, float Bsizey, int _steps, float _minSteps, String _name) {
    sliderInit(Bposx, Bposy, Bsizex, Bsizey, _steps, _minSteps, _name, color(255,200));
  }

  Slider(float Bposx, float Bposy, float Bsizex, float Bsizey, int _steps, float _minSteps, String _name, color _c) {
    sliderInit(Bposx, Bposy, Bsizex, Bsizey, _steps, _minSteps, _name, _c);
  }

  void sliderInit(float Bposx, float Bposy, float Bsizex, float Bsizey, int _steps, float _minSteps, String _name, color _c) {
    steps=_steps;
    barPos = new PVector(Bposx, Bposy);
    sliderPos = new PVector(barPos.x, barPos.y);
    barColor = color(50,180);
    sliderColor = _c;
    barSize = new PVector(Bsizex, Bsizey);
    if (horizontal) sliderSize = new PVector(barSize.x/steps, Bsizey-4);
    else sliderSize = new PVector(Bsizex-4, barSize.y/steps);
    minSteps=_minSteps;
    name=_name;
    slideArea=new PVector(barSize.x-sliderSize.x, barSize.y-sliderSize.y);
  }

  void draw(PGraphics rr)
  {
    rr.rectMode(CENTER);
    rr.noStroke();
    rr.fill(barColor);
    rr.stroke (255);
    rr.strokeWeight(1);

    rr.beginShape();
    rr.vertex(barPos.x-barSize.x/2, barPos.y-barSize.y/4);
    rr.vertex(barPos.x-barSize.x/2+barSize.y/4, barPos.y-barSize.y/2);
    rr.vertex(barPos.x+barSize.x/2-barSize.y/4, barPos.y-barSize.y/2);
    rr.vertex(barPos.x+barSize.x/2, barPos.y-barSize.y/4);
    rr.vertex(barPos.x+barSize.x/2, barPos.y+barSize.y/4);      
    rr.vertex(barPos.x+barSize.x/2-barSize.y/4, barPos.y+barSize.y/2);
    rr.vertex(barPos.x-barSize.x/2+barSize.y/4, barPos.y+barSize.y/2);
    rr.vertex(barPos.x-barSize.x/2, barPos.y+barSize.y/4);
    rr.endShape(CLOSE);

    /*rr.rect(barPos.x, barPos.y, barSize.x*1.02, barSize.y*1.02);
    rr.stroke (255);*/
    rr.textAlign(CENTER);
    if (horizontal)
    {
      rr.line (barPos.x-barSize.x/2+sliderSize.x/2, barPos.y, barPos.x+barSize.x/2-sliderSize.x/2, barPos.y);
      rr.fill(sliderColor);
      for (int i=0; i<=steps; i++)
      {
        rr.line (barPos.x-(barSize.x/2-sliderSize.x/2)+(barSize.x-sliderSize.x)/steps*i, barPos.y+barSize.y*0.35, barPos.x-(barSize.x/2-sliderSize.x/2)+(barSize.x-sliderSize.x)/steps*i, barPos.y-barSize.y*0.35);
      }
      rr.rect(sliderPos.x, barPos.y, sliderSize.x, sliderSize.y);
      rr.fill(255);
      rr.text(round(minSteps), barPos.x-barSize.x/2+20, barPos.y+barSize.y/2-5);
      rr.text(steps+round(minSteps), barPos.x+barSize.x/2-20, barPos.y+barSize.y/2-5);
      rr.text(name, barPos.x, barPos.y-barSize.y+30);
      rr.text(round(power), barPos.x, barPos.y+30);
    } else
    {
      //Code for vertical bars goes here. Unused in project.
    }
  }

  boolean checkClicked()
  {
    if ( mouseX>sliderPos.x-(sliderSize.x/2) && mouseX< sliderPos.x + (sliderSize.x/2)&&mouseY>sliderPos.y-(sliderSize.y/2) && mouseY< sliderPos.y + (sliderSize.y/2))
    {
      return true;
    } else return false;
  }

  void move() //Moves the slider.
  {
    if (horizontal) {
      changeX();
    } else {
      changeY();
    }
  }
  void snap() //Snaps the slider to steps and rounds values to ints on mouse release.
  {
    power=round(map (sliderPos.x, barPos.x-slideArea.x/2, barPos.x+slideArea.x/2, minSteps, steps+minSteps));
    sliderPos.x=barPos.x-slideArea.x/2+slideArea.x/steps*(power-minSteps);
  }

  void snapTo(int power) //Sets the slider to a property.
  {
    sliderPos.x=barPos.x-slideArea.x/2+slideArea.x/steps*(power-minSteps);
  }

  void changeY() //Used in vertical bars.
  {
  }

  void changeX() //Used in horizontal bars, changes the position of the slider.
  {
    if (mouseX<barPos.x+slideArea.x/2&&mouseX>barPos.x-slideArea.x/2)
    {
      sliderPos.x = mouseX;
      power=round(map (sliderPos.x, barPos.x-slideArea.x/2, barPos.x+slideArea.x/2, minSteps, steps+minSteps));
    }
  }
}
