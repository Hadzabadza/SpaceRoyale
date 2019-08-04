/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                 //
//                                Global settings and variables                                    //
//                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////


///////////Instance lists////////////
ArrayList<Star> stars;
//ArrayList<Planet> planets; //MOVED INTO STAR
ArrayList<Asteroid> asteroids;
ArrayList<Bullet> bullets;
ArrayList<Missile> missiles;
ArrayList<Particle> particles;
ArrayList<Particle> spareParticles;
ArrayList<Object> destroyees;
ArrayList<Object> newSpawns;
ArrayList<Object> objects;
Ship[] ships;
PGraphics[] screen;
IMG sprites;
ArrayList<View> view;
Terrain[] propMatrix=new Terrain[8]; //Used in propagation calculation
float[] propRatios=new float[8];
 
/////////////////GFX/////////////////
PFont pixFont;
int spareParts=0;

////////////////MISC/////////////////
static float FMAX=3.40282347E+38;
float gameTime=0;
long seed=623456146;
int gameState=0;
color backgroundColour= color(0);

//////////////OSC stuff//////////////
OscHub osc;

/////////!!!!!FIX THESE!!!!!/////////
//PVector mapScreenShift;
//boolean mapScreen;
Terrain active;
PVector cursor;

static class Settings {

  //Game settings
  static int backgroundColor=50;
  static int FPS=60;          //For debug
  static boolean DEBUG=true; //
  static boolean drawObjectsOnlyInRange=true;

  //Generator settings
  static int ships=1;              // SHIPS HERE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  static int minPlanetsPerStar =3;
  static int maxPlanetsPerStar =8;
  static int minAsteroidsPerChain =1;
  static int maxAsteroidsPerChain =8;
  static float celestialPull=0.00008;

  //OSC stuff
  static String[] controllerIP={
    "10.0.50.20", 
    "192.168.0.105", 
    "192.168.1.162", 
    "192.168.1.162", 
    "192.168.1.162", 
    "192.168.1.162", 
    "192.168.1.162", 
    "192.168.1.162"};
  static int[] oscInPort={
    8000, 
    8001, 
    8002, 
    8003, 
    8004, 
    8005, 
    8006, 
    8007};
  static int[] controllerInputPort={
    9000, 
    9001, 
    9002, 
    9003, 
    9004, 
    9005, 
    9006, 
    9007};
  static boolean decodeOSC=true;            //For debug
  static boolean displayOSCBundleLogs=false; //
  static int refreshInterval=120;
  static int planetLocationUpdateInterval=30;

  //Star properties
  static float minStarMass=2000000;
  static float maxStarMass=16000000;
  static float minStarTemp=1000;
  //static float temperatureFalloff=

  //Planet properties
  static float gravityWellRadiusMultiplier=10;
  static int planetScaler=4;
  
  //Ship properties
  static float shipSize=22; //Radius of ship entities
  static float turretGfxSize=20; //Extra radius around the ship for turret graphics
  static float projectileSpeed=6; //Bullet's muzzle velocity
  static float minWarpSpeed=20; //Minimum warp speed
  static float maxWarpSpeed=80; //Maximum warp speed
  static float fireCooldown=0.1;
  static float targetingDistance=2550;
  static float staticTurnSpeed=0.0002;
  static float assistedTurnSpeed=0.00035;
  static float afterBurnerMaxCap=3;
  static int turretXOffset=-2;
  static int turretYOffset=8;
  static int msslSlotXOffset=13;
  static int msslSlotYOffset=-26;
  static int msslAmount=2;
  static float heatRadiationRate=0.999;
  static float heatConductivityRate=0.1;
  static float hullAlbedo=0.8;
  static int hullMeltingPoint=2200;
  static float hullPieceMass=100;
  static float hullPieceArea=10; //Hull piece = square, therefore radiating area of its piece is its length sqrt(hullPieceMass).
  static float shipDrawScale=0.2;

  //Bullet properties
  static float bullDmg=0.1;
  static int bullSelfDestructTimer=1200;
  static int bullInactivityTimer=25;

  //Missile properties
  static float msslDmg=0.3;
  static int msslSelfDestructTimer=1200;
  static int msslFuel=200;
  static int msslInactivityTimer=20;
  static float msslMaxSpin=0.017; //2 Degrees
  static float msslAcceleration=0.1;

  //Particle properties
  static float alphaChange=-1.5;
  static float scaleChange=-0.001;
  static float defaultTimer=255;
}
