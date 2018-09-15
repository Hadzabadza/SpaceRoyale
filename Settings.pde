//Generator settings
static class Settings {

  //Game settings
  static int backgroundColor=50;
  static int FPS=5; //For debug
  
  //Generation
  static int minPlanetsPerStar =3;
  static int maxPlanetsPerStar =8;
  static int ships=2;


  //OSC stuff
  static String[] controllerIP={"192.168.1.162", "192.168.1.162"};
  static int[] oscInPort={8000, 8001};
  static int[] controllerInputPort={9000, 9001};
  static boolean decodeOSC=false; //For debug

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