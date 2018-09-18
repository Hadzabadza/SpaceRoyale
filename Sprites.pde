PImage IMGShip;
PImage IMGShipStripes;
PImage IMGTurret;
PImage IMGShell;
PImage IMGShieldWaves;
PImage IMGMissile;
PImage IMGMissileExhaust;
PImage IMGExhaustSmoke;
int debrisImages=8;
PImage[] IMGDebris;
int msslSlotImages=2;
PImage[] IMGMissileSlot;

void loadImages() {
  IMGShip=loadImage("data/img/CruiserNoTransparents.png");
  IMGShipStripes=loadImage("data/img/CruiserTransparents.png");
  IMGShell=loadImage("data/img/Shell.png");
  IMGTurret=loadImage("data/img/Turret.png");
  IMGShieldWaves=loadImage("data/img/Shield.png");
  IMGMissile=loadImage("data/img/GuidedMissile.png");
  IMGMissileExhaust=loadImage("data/img/GuidedMissileExhaust.png");
  IMGExhaustSmoke=loadImage("data/img/particles/Jet.png");
  IMGDebris=new PImage[debrisImages];
  for (int i=0; i<debrisImages; i++) IMGDebris[i]=loadImage("data/img/particles/Debris"+i+".png");
  IMGMissileSlot=new PImage[msslSlotImages];
  for (int i=0; i<msslSlotImages; i++) IMGMissileSlot[i]=loadImage("data/img/MissileSlot"+i+".png");
}