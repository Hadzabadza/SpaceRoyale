class Particle extends Object {
  color c;
  float alpha;
  float alphaChange;
  float scale;
  float scaleChange;
  float rotation;
  float timer;
  float largerSide;
  PImage sprt = null;

  Particle(PImage inputImg) {
    super(new PVector(width/2-inputImg.width/2, height/2-inputImg.height/2), new PVector(random(-2, 2), random(-2, 2)), random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos) {
    super(_pos, new PVector(random(-2, 2), random(-2, 2)), random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel) {
    super( _pos, _vel, random(0, TWO_PI), 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }

  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir) {
    super( _pos, _vel, _dir, 0);
    sprt = inputImg;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }
  
  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir, color _c) {
    super( _pos, _vel, _dir, 0);
    sprt = inputImg;
    c=_c;
    alpha=alpha(c);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    findLargerSide();
  }
  
  Particle(PImage inputImg, PVector _pos, PVector _vel, float _dir, color _c, float _scale, float _alphaChange, float _scaleChange, float _rotation, float _timer) {
    super( _pos, _vel, _dir, 0);
    sprt = inputImg;
    c=_c;
    alpha=alpha(c);
    scale=_scale;
    alphaChange=_alphaChange;
    scaleChange=_scaleChange;
    rotation=_rotation;
    timer=_timer;
    findLargerSide();
  }

  void update() {
    alpha+=alphaChange;
    scale+=scaleChange;
    dir+=rotation;
    radius=largerSide*scale;
    super.update();
    timer--;
    if ((scale<=0)||(alpha<=0)||(timer<=0)) queueDestroy();
  }

  void draw(PGraphics rr) {
    c=color(red(c), green(c), blue(c), alpha);
    rr.pushMatrix();
    rr.tint(c);
    rr.translate(pos.x, pos.y);
    rr.rotate(dir);
    rr.scale(scale);
    rr.image(sprt, -sprt.width/2, -sprt.height/2);
    rr.popMatrix();
  }

  void refresh(PImage _sprt, PVector _pos) {
    pos.x=_pos.x;
    pos.x=_pos.y;
    vel.x=random(-2, 2);
    vel.y=random(-2, 2);
    sprt = _sprt;
    alpha=random(100, 255);
    c=color(255, alpha);
    scale=1;
    alphaChange=random(-1,Settings.alphaChange);
    scaleChange=Settings.scaleChange;
    rotation=random(-0.05, 0.05);
    timer=Settings.defaultTimer;
    destroyed=false;
  }

  void findLargerSide(){
    if (sprt.height>sprt.width) largerSide=sprt.height;
    else largerSide=sprt.width;
  }

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
    spareParts++;*///FetchKvetch stuff
  }
}
