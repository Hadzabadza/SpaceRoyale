/////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                 //
//                                Global settings and variables                                    //
//                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////


///////////Instance lists////////////
ArrayList<Star> stars;
ArrayList<Planet> planets;
ArrayList<Asteroid> asteroids;
ArrayList<Bullet> bullets;
ArrayList<Particle> particles;
ArrayList<Particle> spareParticles;
ArrayList<Object> destroyees;
ArrayList<Object> newSpawns;
ArrayList<Object> objects;
Ship[] ships;
PGraphics[] screen;

/////////////////GFX/////////////////
PFont pixFont;
int spareParts=0;

////////////////MISC/////////////////
static float FMAX=3.40282347E+38;
long seed=1;
int gameState=0;

/////?////////OSC stuff////////?/////
OscHub osc;

/////////!!!!!FIX THESE!!!!!/////////
PVector mapScreenShift;
boolean mapScreen;
boolean heightColour;
Terrain active;
PVector cursor;
//int tSize=50;

static class Settings {

  //Game settings
  static int backgroundColor=50;
  static int FPS=60;          //For debug
  static boolean DEBUG=false; //

  //Generator settings
  static int minPlanetsPerStar =3;
  static int maxPlanetsPerStar =8;
  static int ships=2;              // SHIPS HERE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


  //OSC stuff
  static String[] controllerIP={
    "192.168.1.162", 
    "192.168.1.162", 
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
  static boolean decodeOSC=false;            //For debug
  static boolean displayOSCBundleLogs=false; //
  static int refreshInterval=120;
  static int planetLocationUpdateInterval=30;

  //Ship properties
  static float shipSize=20; //Radius of ship entities
  static float turretGfxSize=20; //Extra radius around the ship for turret graphics
  static float projectileSpeed=2; //Bullet's muzzle velocity
  static float warpCap=10; //Maximum warp speed
  static float fireCooldown=0.1;
  static float targetingDistance=1250;
  static float staticTurnSpeed=0.02;
  static float assistedTurnSpeed=0.035;
  static int turretXOffset=-2;
  static int turretYOffset=8;

  //Bullet properties
  static float bullDmg=0.1;
  static int selfDestructTimer=1200;
  static int inactivityTimer=25;
  
  //Particle properties
  static float alphaChange=-5;
  static float scaleChange=-0.01;

  /*enum ShipColors {
    red, 
      green, 
      blue, 
      yellow, 
      purple, 
      gray, 
      orange, 
      brown
  }*/
}