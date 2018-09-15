//TODO: stop sending orbital data when OM page is not active

class OscHub {
  int OMPlanets; //TouchOSC orbital map planets count
  int OMPlanetSize=10; //Width/height of a planet on display
  int displaySize=280; //Smallest dimension of the display
  int OMCorrectionOffset=-5; //Offset the LEDs by this ammount (they are drawn from top-left)
  int OMCenterX=240; //Centre of the orbital map screen
  int OMCenterY=140;
  int[] OMPlanetDistances; //Distances between planets in touchOSC space
  int longestDistance; //Farthest star
  int turnWheelPosX=108; //Properties of the turn wheel
  int turnWheelPosY=10;
  int turnWheelRadius=120;
  OscDock[] dock; //Multiple docks for multiple controllers

  OscHub(int controllers) { //Hub that computes the messages before sending
    dock=new OscDock[controllers];
    for (int i=0; i<controllers; i++) dock[i]=new OscDock(this, i, new NetAddress(Settings.controllerIP[i], Settings.controllerInputPort[i]), Settings.oscInPort[i], ships[i]);

    //initializeHub();
    OMPlanets=planets.size();
    OMPlanetDistances=new int[OMPlanets];
    longestDistance=round(planets.get(OMPlanets-1).distance);
    longestDistance=longestDistance/100;
    for (int i=0; i<OMPlanets; i++) OMPlanetDistances[i]=round(planets.get(i).distance/longestDistance);
    for (OscDock d : dock) d.initializeDock();
  }

  void initializeHub() { //Initializing Orbital Map data
  }

  void update() { //
    OscBundle refreshBundle=new OscBundle();
    if (frameCount%120==0) {      
      refreshBundle.add(new OscMessage("/OM/star").add(1));
      refreshBundle.add(new OscMessage("/OM/ship").add(1));
      refreshBundle.add(new OscMessage("/SC/directionIndicator").add(1));
      refreshBundle.add(new OscMessage("/OM/label35/visible").add(0));
      refreshBundle.add(new OscMessage("/FC/centreIndicator").add(1));
    }
    for (OscDock d : dock) {
      OscBundle updateBundle = new OscBundle(); 
      d.bundleLog.add("UBundle-C"+d.id+". Initial segment. Size: "+updateBundle.size());
      updateBundle=refreshBundle;
      d.bundleLog.add("UBundle-C"+d.id+". Refresh segment. Size: "+updateBundle.size());
      d.sendUpdates(updateBundle);
    }
  }

  void OMPlanetMove(OscDock d, OscBundle outBundle, int targetPlanetIndex) {
    int OMPlanetPosX=round(planets.get(targetPlanetIndex).pos.x/longestDistance+OMCenterX+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/x").add(OMPlanetPosX));
    int OMPlanetPosY=round(planets.get(targetPlanetIndex).pos.y/longestDistance+OMCenterY+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/y").add(OMPlanetPosY));
    d.bundleLog.add("UBundle-C"+d.id+". Planet position segment. Size: "+outBundle.size());
  }


  public void exit() {
    OscBundle exitBundle = new OscBundle();
    exitBundle.add(new OscMessage("/OM/star").add(0));     
    exitBundle.add(new OscMessage("/OM/ship").add(0));     
    exitBundle.add(new OscMessage("/SC/directionIndicator").add(0));     
    exitBundle.add(new OscMessage("/OM/label35/visible").add(1));     
    for (int i=0; i<OMPlanets; i++) exitBundle.add(new OscMessage("/OM/planet"+i).add(0));
    for (OscDock d : dock) d.send(exitBundle);
  }
}

class OscDock {
  OscHub hub;
  OscP5 ex;
  Ship s;
  NetAddress c;
  int activePage=0;
  boolean activated;
  boolean unlocked;
  boolean cleared;
  boolean changeLandingButton;
  ArrayList<String> bundleLog;
  int id;

  OscDock(OscHub _hub, int _id, NetAddress _c, int port, Ship _s) {
    ex=new OscP5(this, port);
    hub=_hub;
    c=_c;
    s=_s;
    s.dock=this;
    id=_id;
    plugs();
    bundleLog=new ArrayList<String>();
  }

  void initializeDock() {
    OscBundle startBundle = new OscBundle(); //<>//
    startBundle.add(new OscMessage("/SC"));
    startBundle.add(new OscMessage("/OM/star").add(1));     
    startBundle.add(new OscMessage("/OM/ship").add(1));     
    startBundle.add(new OscMessage("/SC/directionIndicator").add(1));     
    startBundle.add(new OscMessage("/OM/label35/visible").add(0));     
    for (int i=0; i<hub.OMPlanets; i++) startBundle.add(new OscMessage("/OM/planet"+i).add(1));     
    for (int i=hub.OMPlanets; i<Settings.maxPlanetsPerStar; i++) startBundle.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
    startBundle.add(new OscMessage("/OM/zoom").add(0.84));
    startBundle.setTimetag(startBundle.now());
    bundleLog.add("StartBundle-C"+id+". Size: "+startBundle.size());
    lockScreenGreen(startBundle);
    send(startBundle);
  }

  void sendUpdates(OscBundle uB) {
    if (!activated) lockScreenGreen(uB);
    else
    {
      if (unlocked) {
        if (!cleared) lockScreenClear(uB);
        if (activePage==0) {
          displaceDirectionIndicator(uB);
        }
        if (activePage==2) {
          for (int i=0; i<hub.OMPlanets; i++) uB.add(new OscMessage("/OM/planet"+i).add(1));
          for (int i=hub.OMPlanets; i<Settings.maxPlanetsPerStar; i++) uB.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
          for (int i=0; i<hub.OMPlanets; i++) hub.OMPlanetMove(this, uB, i);
        }
        if (changeLandingButton) {
          if (s.land!=null) uB.add(new OscMessage("/SC/planetView/color").add("green"));
          else uB.add(new OscMessage("/SC/planetView/color").add("gray"));
          bundleLog.add("UBundle-C"+id+". Land button segment. Size: "+uB.size());
          changeLandingButton=false;
        }
        bundleLog.add("UBundle-C"+id+". Dock updates. Size: "+uB.size());
      }
    }
    send(uB);
  }

  public void displaceDirectionIndicator(OscBundle uB) { //Don't use alone! Adds to bundle
    uB.add(new OscMessage("/SC/directionIndicator/position/x").add(hub.OMCorrectionOffset+round(hub.turnWheelPosX+hub.turnWheelRadius+hub.turnWheelRadius*cos(radians(s.dir)))));
    uB.add(new OscMessage("/SC/directionIndicator/position/y").add(hub.OMCorrectionOffset+round(hub.turnWheelPosY+hub.turnWheelRadius+hub.turnWheelRadius*sin(radians(s.dir)))));
    bundleLog.add("UBundle-C"+id+". DI segment. Size: "+uB.size());
  }

  void OMShipMove(OscBundle uB) { //Don't use alone! Adds to bundle
    int OMShipPosX=round(s.pos.x/hub.longestDistance+hub.OMCenterX+hub.OMCorrectionOffset);
    if (OMShipPosX>hub.OMCenterX*2) OMShipPosX=hub.OMCenterX*2;
    else if (OMShipPosX<0) OMShipPosX=0;
    int OMShipPosY=round(s.pos.y/hub.longestDistance+hub.OMCenterY+hub.OMCorrectionOffset);
    if (OMShipPosY>hub.OMCenterY*2) OMShipPosY=hub.OMCenterY*2; 
    else if (OMShipPosY<0) OMShipPosY=0;
    uB.add(new OscMessage("/OM/ship/position/x").add(OMShipPosX));
    uB.add(new OscMessage("/OM/ship/position/y").add(OMShipPosY));
  }

  void landingChange() {
    changeLandingButton=true;
  }

  void oscEvent(OscMessage theOscMessage) { //Print the address pattern and the typetag of the received OscMessage
    if (!activated) {
      activated=true;
    }
    if (Settings.decodeOSC) {
      print("### OSC Msg: ");
      print("addrpattern: "+theOscMessage.addrPattern());
      println(" typetag: "+theOscMessage.typetag());
    }
  }

  void lockScreenGreen(OscBundle b) {
    b.add(new OscMessage("/SC/connectionStatus/visible").add(1));
    b.add(new OscMessage("/SC/connectionStatus").add("Connected"));
    b.add(new OscMessage("/SC/connectionStatus/color").add("green"));
    b.add(new OscMessage("/SC/screenBlock/color").add("green"));
    b.add(new OscMessage("/SC/tapHint/position/y").add(202));
    bundleLog.add("UBundle-C"+id+". Lock screen update segment. Size: "+b.size());
  }

  void lockScreenClear(OscBundle b) {
    cleared=true;
    b.add(new OscMessage("/SC/connectionStatus/visible").add(0));
    b.add(new OscMessage("/SC/screenBlock/visible").add(0));
    b.add(new OscMessage("/SC/tapHint/visible").add(0));
    bundleLog.add("UBundle-C"+id+". Lock screen clearer segment. Size: "+b.size());
  }


  void send(OscBundle b) {
    bundleLog.add("UBundle-C"+id+". Sending... Size: "+b.size());
    if (Settings.displayOSCBundleLogs) for (String s : bundleLog) println(s);
    if (b.size()>0) {
      b.setTimetag(b.now());
      ex.send(b, c);
    }
  }

  void send(OscMessage m) {
    ex.send(m, c);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                                                                 //
  //                                            Plugs                                                //
  //                                                                                                 //
  /////////////////////////////////////////////////////////////////////////////////////////////////////

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
    ex.plug(this, "switchToSC", "/SC");
    ex.plug(this, "switchToPV", "/PV");
    ex.plug(this, "switchToOM", "/OM");
    ex.plug(this, "switchToFC", "/FC");
    ex.plug(this, "unlock", "/SC/screenBlock");
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
  void switchToSC() {
    activePage=0;
  }
  void switchToPV() {
    activePage=1;
  }
  void switchToOM() {
    activePage=2;
  }
  void switchToFC() {
    activePage=3;
  }
  void unlock(float f) {
    unlocked=true;
  }
}