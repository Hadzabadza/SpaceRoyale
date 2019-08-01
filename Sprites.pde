class IMG{
PImage Ship;
PImage ShipStripes;
PImage Turret;
PImage Shell;
PImage ShieldWaves;
PImage Missile;
PImage MissileExhaust;
PImage ExhaustSmoke;
PImage StarryBack;
int debrisImages=8;
PImage[] Debris;
int msslSlotImages=2;
PImage[] MissileSlot;

void loadImages() {
  Ship=loadImage("data/img/CruiserNoTransparents.png");
  ShipStripes=loadImage("data/img/CruiserTransparents.png");
  Shell=loadImage("data/img/Shell.png");
  Turret=loadImage("data/img/Turret.png");
  ShieldWaves=loadImage("data/img/Shield.png");
  Missile=loadImage("data/img/GuidedMissile.png");
  MissileExhaust=loadImage("data/img/GuidedMissileExhaust.png");
  ExhaustSmoke=loadImage("data/img/particles/Jet.png");
  StarryBack=loadImage("data/img/StarryBack.png"); //Taken from https://background-tiles.com
  Debris=new PImage[debrisImages];
  for (int i=0; i<debrisImages; i++) Debris[i]=loadImage("data/img/particles/Debris"+i+".png");
  MissileSlot=new PImage[msslSlotImages];
  for (int i=0; i<msslSlotImages; i++) MissileSlot[i]=loadImage("data/img/MissileSlot"+i+".png");
}
}
