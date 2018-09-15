//TODO: stop sending orbital data when OM page is not active

class OscHub {
  int OMPlanets; //TouchOSC orbital map planets count
  int OMPlanetSize=10; //Width/height of a planet on display
  int displaySize=280; //Smallest dimension of the display
  int OMCorrectionOffset=-5; //Offset the LEDs by this ammount (they are drawn from top-left)
  int OMCenterX=240;
  int OMCenterY=140;
  int[] OMPlanetDistances; //Distances between planets in touchOSC space
  int longestDistance;
  int turnWheelPosX=108;
  int turnWheelPosY=10;
  int turnWheelRadius=120;
  OscDock[] dock;

  OscHub(int controllers) {
    dock=new OscDock[controllers];
    println(dock.length);
    for (int i=0; i<controllers; i++) dock[i]=new OscDock(this, new NetAddress(Settings.controllerIP[i], Settings.controllerInputPort[i]), Settings.oscInPort[i], ships[i]);
    OMStart();
  }

  void OMStart() { //Initializing Orbital Map data
    OMPlanets=planets.size();
    OMPlanetDistances=new int[OMPlanets];
    longestDistance=round(planets.get(OMPlanets-1).distance);
    longestDistance=longestDistance/100;
    for (int i=0; i<OMPlanets; i++) OMPlanetDistances[i]=round(planets.get(i).distance/longestDistance);
    println(dock.length);
    for (OscDock d:dock) d.start();
  }

  void OMUpdate() {
    OscBundle updateBundle = new OscBundle();    
    if (frameCount%120==0) {      
      updateBundle.add(new OscMessage("/OM/star").add(1));
      updateBundle.add(new OscMessage("/OM/ship").add(1));
      updateBundle.add(new OscMessage("/SC/directionIndicator").add(1));
      updateBundle.add(new OscMessage("/OM/label35/visible").add(0));
      updateBundle.add(new OscMessage("/FC/centreIndicator").add(1));
      for (int i=0; i<OMPlanets; i++) updateBundle.add(new OscMessage("/OM/planet"+i).add(1));
      for (int i=OMPlanets; i<Settings.maxPlanetsPerStar; i++) updateBundle.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
      for (int i=0; i<OMPlanets; i++) OMPlanetMove(updateBundle, i);
    }
    for (OscDock d : dock) d.sendUpdates(updateBundle);
  }

  void OMPlanetMove(OscBundle outBundle, int targetPlanetIndex) {
    int OMPlanetPosX=round(planets.get(targetPlanetIndex).pos.x/longestDistance+OMCenterX+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/x").add(OMPlanetPosX));
    int OMPlanetPosY=round(planets.get(targetPlanetIndex).pos.y/longestDistance+OMCenterY+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/y").add(OMPlanetPosY));
  }


  public void exit() {
    OscBundle exitBundle = new OscBundle();
    exitBundle.add(new OscMessage("/OM/star").add(0));     
    exitBundle.add(new OscMessage("/OM/ship").add(0));     
    exitBundle.add(new OscMessage("/SC/directionIndicator").add(0));     
    exitBundle.add(new OscMessage("/OM/label35/visible").add(1));     
    for (int i=0; i<OMPlanets; i++) exitBundle.add(new OscMessage("/OM/planet"+i).add(0));
    for (OscDock d:dock) d.send(exitBundle);
  }
}

class OscDock {
  OscHub hub;
  OscP5 ex;
  Ship s;
  NetAddress c;

  OscDock(OscHub _hub, NetAddress _c, int port, Ship _s) {
    ex=new OscP5(this, port);
    hub=_hub;
    c=_c;
    s=_s;
    plugs();
}
  
  void start() {
    OscBundle startBundle = new OscBundle();
    startBundle.add(new OscMessage("/OM/star").add(1));     
    startBundle.add(new OscMessage("/OM/ship").add(1));     
    startBundle.add(new OscMessage("/SC/directionIndicator").add(1));     
    startBundle.add(new OscMessage("/OM/label35/visible").add(0));     
    for (int i=0; i<hub.OMPlanets; i++) startBundle.add(new OscMessage("/OM/planet"+i).add(1));     
    for (int i=hub.OMPlanets; i<Settings.maxPlanetsPerStar; i++) startBundle.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
    startBundle.add(new OscMessage("/OM/zoom").add(0.84));
    startBundle.setTimetag(startBundle.now());
    send(startBundle);
  }

  void sendUpdates(OscBundle uB) {
    displaceDirectionIndicator(uB);
    if (s.land!=null) uB.add(new OscMessage("/SC/planetView/color").add("green"));
    else uB.add(new OscMessage("/SC/planetView/color").add("gray"));
    uB.setTimetag(uB.now());
    send(uB);
  }

  public void displaceDirectionIndicator(OscBundle uB) { //Don't use alone! Additive to bundle
    uB.add(new OscMessage("/SC/directionIndicator/position/x").add(hub.OMCorrectionOffset+round(hub.turnWheelPosX+hub.turnWheelRadius+hub.turnWheelRadius*cos(radians(s.dir)))));
    uB.add(new OscMessage("/SC/directionIndicator/position/y").add(hub.OMCorrectionOffset+round(hub.turnWheelPosY+hub.turnWheelRadius+hub.turnWheelRadius*sin(radians(s.dir)))));
  }

  void send(OscBundle b) { 
    ex.send(b,c);
  }

  void send(OscMessage m) { 
    ex.send(m,c);
  }

  void OMShipMove(OscBundle uB) { //Don't use alone! Needs the bundle sent at some point after use
    int OMShipPosX=round(s.pos.x/hub.longestDistance+hub.OMCenterX+hub.OMCorrectionOffset);
    if (OMShipPosX>hub.OMCenterX*2) OMShipPosX=hub.OMCenterX*2;
    else if (OMShipPosX<0) OMShipPosX=0;
    int OMShipPosY=round(s.pos.y/hub.longestDistance+hub.OMCenterY+hub.OMCorrectionOffset);
    if (OMShipPosY>hub.OMCenterY*2) OMShipPosY=hub.OMCenterY*2; 
    else if (OMShipPosY<0) OMShipPosY=0;
    uB.add(new OscMessage("/OM/ship/position/x").add(OMShipPosX));
    uB.add(new OscMessage("/OM/ship/position/y").add(OMShipPosY));
  }

  void plugs() {
    ex.plug(this, "changeThrottle", "/SC/throttle");
    ex.plug(this, "warp", "/SC/warp");
    ex.plug(this, "turnLeft", "/SC/turnLeft");
    ex.plug(this, "turnRight", "/SC/turnRight");
    ex.plug(this, "enterPlanet", "/SC/planetView");
    ex.plug(this, "turnTo", "/SC/turnWheel");
    ex.plug(this, "moveCursor", "/PV/locator");
    ex.plug(this, "placeVolcano", "/PV/placeVolcano");
    ex.plug(this, "heightView", "/PV/heightView");
    ex.plug(this, "changeZoom", "/OM/zoom");
    ex.plug(this, "shoot", "/FC/fire");
    ex.plug(this, "changeAim", "/FC/targeter");
    ex.plug(this, "pageSwitch", "/SC");
    ex.plug(this, "pageSwitch", "/PV");
    ex.plug(this, "pageSwitch", "/OM");
  }

  public void changeThrottle(float f) {
    s.thrust=f;
  }
  public void warp(float f) {
    s.warp=!s.warp;
  }
  public void turnLeft(float f) {
    if (f==0) s.turnLeft=false;
    else s.turnLeft=true;
  }
  public void turnRight(float f, OscBundle outBundle) {
    if (f==0) s.turnRight=false;
    else s.turnRight=true;
  }

  public void enterPlanet(float f) {
    if (mapScreen==true)  
    {
      mapScreen=false;
      active=null;
    } else if (s.land!=null) {
      mapScreen=true;
      s.thrust=0;
      ex.send(new OscMessage("/PV"));
    }
  }

  public void turnTo(float f) {
    s.dir+=(s.thrust+1)*f;
  }

  public void moveCursor(float x, float y)
  {
    if (s.land!=null) {
      int xOffset=(width-s.land.map.width)/2;
      int yOffset=(height-s.land.map.height)/2;
      cursor.x=xOffset+x*ships[0].land.map.width;
      cursor.y=yOffset+y*ships[0].land.map.height;
    }
  }

  public void placeVolcano(float f) {
    if (s.land!=null) 
    {
      Terrain t=s.land.pickTile();
      if (t!=null) t.volcanize();
    }
  }

  public void heightView(float f)
  {
    heightColour=!heightColour;
  }

  public void changeZoom(float f) {
    s.zoom=0.8+9.2*(1-f)*(1-f);
  }

  public void shoot(float f) {
    s.shoot();
  }

  public void changeAim(float x, float y)
  {
    s.aimDir=atan2(y-0.5, x-0.5)-HALF_PI;
  }
}