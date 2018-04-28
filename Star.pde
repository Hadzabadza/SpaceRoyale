  class Star {
  float mass;
  float radius;
  float AOE;
  PVector pos;

  Star() {
    pos= new PVector();
    mass=random(100, 1000);
    radius=sqrt(mass)*5;
    pos.x=round(random(-width, width));
    pos.y=round(random(-height, height));
    float distS=random(50, 300);
    for (int i=0; i<round(random(1, 3)); i++) {
      float pMass=random(10, 100);
      distS+=random(40, 100)+sqrt(pMass)*5*2;
      planets.add(new Planet(this, pMass, distS, i+1));
    }
  }

  Star(float x, float y) {
    pos= new PVector();
    mass=random(100, 1000);
    radius=sqrt(mass)*5;
    pos.x=x;
    pos.y=y;
    float distS=random(500, 1000);
    for (int i=0; i<round(random(3, 8)); i++) {
      float pMass=random(10, 100);
      distS+=random(100, 1000)+sqrt(pMass)*5*2;
      planets.add(new Planet(this, pMass, distS, i+1));
    }
  }
  Star(float mass_) {
  }

  void draw()
  {
    stroke(0);
    fill(255, 200, 40);
    ellipse (pos.x, pos.y, radius*2, radius*2);
  }
}