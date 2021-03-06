class Particle extends Object {
  color c;
  float alpha;
  float alphaChange;
  float scale;
  float scaleChange;
  float timer;
  float largerSide;
  boolean isDebris;
  PImage sprt = null;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

Particle(PImage inputImg) {
    super(new PVector(width/2-inputImg.width/2, height/2-inputImg.height/2), new PVector(random(-2, 2), random(-2, 2)), random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1, Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    spin=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos) {
    super(_pos, new PVector(random(-2, 2), random(-2, 2)), random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1, Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    spin=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel) {
    super( _pos, _vel, random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1, Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    spin=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir) {
    super( _pos, _vel, _dir, 0);
    partInit(inputImg, color(255,random(100,255)), 1, random(-1, Settings.alphaChange), Settings.scaleChange, random(-0.05, 0.05), Settings.defaultTimer, false); 
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir, color _c) {
    super( _pos, _vel, _dir, 0);
    partInit(inputImg, _c, 1, random(-1, Settings.alphaChange), Settings.scaleChange, random(-0.05, 0.05), Settings.defaultTimer, false); 
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir, color _c, float _scale, float _alphaChange, float _scaleChange, float _rotation, float _timer, boolean _isDebris) {
    super( _pos, _vel, _dir, 0);
    partInit(inputImg, _c, _scale, _alphaChange, _scaleChange, _rotation,_timer, _isDebris); 
  }
  
  void partInit(PImage inputImg, color _c, float _scale, float _alphaChange, float _scaleChange, float _rotation, float _timer, boolean _isDebris){
    sprt = inputImg;
    c=_c;
    alpha=c >> 24 & 0xFF;
    scale=_scale;
    alphaChange=_alphaChange;
    scaleChange=_scaleChange;
    spin=_rotation;
    timer=_timer;
    isDebris=_isDebris;
    findLargerSide();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  float findLargerSide() {
    if (sprt.height>sprt.width) return sprt.height;
    else return sprt.width;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void refresh(PImage _sprt, PVector _pos) {
    pos.x=_pos.x;
    pos.x=_pos.y;
    vel.x=random(-2, 2);
    vel.y=random(-2, 2);
    sprt = _sprt;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1, Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    spin=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    destroyed=false;
  }
  void update() {
    alpha+=alphaChange;
    scale+=scaleChange;
    radius=largerSide*scale;
    super.update();
    timer--;
    if ((scale<=0)||(alpha<=0)||(timer<=0)) queueDestroy();
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

void draw(PGraphics rr) {
    if (isDebris) {
      c=color(red(c), green(c), blue(c), alpha);
      rr.pushMatrix();
      rr.tint(c);
      rr.translate(pos.x, pos.y);
      rr.rotate(dir);
      if (ships[0].zoom>0.5) rr.scale(scale*ships[0].zoom*2);
      else rr.scale(scale);
      rr.image(sprt, -sprt.width/2, -sprt.height/2);
      rr.popMatrix();
    } else {
      c=color(red(c), green(c), blue(c), alpha);
      rr.pushMatrix();
      rr.tint(c);
      rr.translate(pos.x, pos.y);
      rr.rotate(dir);
      if (ships[0].zoom>1) rr.scale(scale*sqrt(ships[0].zoom));
      else rr.scale(scale);
      rr.image(sprt, -sprt.width/2, -sprt.height/2);
      rr.popMatrix();
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void spawn() {
    objects.add(this);
    particles.add(this);
  }
  void queueDestroy() {
    destroyees.add(this);
  }
  void destroy() {
    destroyed=true;
    objects.remove(this);
    particles.remove(this);
    /*spareParticles.add(this);
     spareParts++;*/    //FetchKvetch stuff
  }
}
