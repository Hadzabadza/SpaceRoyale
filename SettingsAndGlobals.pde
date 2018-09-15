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
ArrayList<Object> destroyees;
ArrayList<Object> newSpawns;
ArrayList<Object> objects;
Ship[] ships;
PGraphics[] screen;

/////////////////GFX/////////////////
PFont pixFont;

////////////////MISC/////////////////
long seed=1;

/////////!!!!!FIX THESE!!!!!/////////
PVector mapScreenShift;
boolean mapScreen;
boolean heightColour;
Terrain active;
PVector cursor;
//int tSize=50;

/////?////////OSC stuff////////?/////
OscHub osc;

static class Settings {

  //Game settings
  static int backgroundColor=50;
  static int FPS=60;          //For debug
  static boolean DEBUG=false; //

  //Generator settings
  static int minPlanetsPerStar =3;
  static int maxPlanetsPerStar =8;
  static int ships=1;


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
  static boolean decodeOSC=true;            //For debug
  static boolean displayOSCBundleLogs=false; //
  static int refreshInterval=120;
  static int planetLocationUpdateInterval=30;

  //Ship properties
  static float shipSize=7.5; //Radius of ship entities
  static float turretGfxSize=5; //Extra radius around the ship for turret graphics
  static float projectileSpeed=2; //Bullet's muzzle velocity
  static float warpCap=10; //Maximum warp speed
  static float fireCooldown=0.1;

  //Bulletproperties
  static float bullDmg=0.1;

  /*static enum ShipColors {
   RED,
   GREEN,
   BLUE,
   CYAN,
   MAGENTA,
   YELLOW,
   BROWN,
   GREY
   }*/
}