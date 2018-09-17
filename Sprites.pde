PImage IMGShip;
PImage IMGShipStripes;
PImage IMGTurret;
PImage IMGShell;
PImage IMGShieldWaves;
int debrisImages=8;
PImage[] IMGDebris;

void loadImages(){
  IMGShip=loadImage("data/img/CruiserNoTransparents.png");
  IMGShipStripes=loadImage("data/img/CruiserTransparents.png");
  IMGShell=loadImage("data/img/Shell.png");
  IMGTurret=loadImage("data/img/Turret.png");
  IMGShieldWaves=loadImage("data/img/Shield.png");
  IMGDebris=new PImage[debrisImages];
  for (int i=0; i<debrisImages; i++) IMGDebris[i]=loadImage("data/img/particles/Debris"+i+".png");
}