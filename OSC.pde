class OscHub { //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  OscDock[] dock; //Multiple docks with specific data for multiple controllers 
  int displaySize=280; //Smallest dimension of the display
  int longestDistance; //Farthest star

  int OMPlanets; //TouchOSC orbital map planets count
  int OMPlanetSize=10; //Width/height of a planet on display
  int OMLEDCorrectionOffset=-5; //Offset the planet (and ship) LEDs by this ammount 

  OscHub(int controllers) { //Hub that computes the messages before sending
    dock=new OscDock[controllers];
    for (int i=0; i<controllers; i++) dock[i]=new OscDock(this, i, new NetAddress(Settings.controllerIP[i], Settings.controllerInputPort[i]), Settings.oscInPort[i], ships[i]);
    //initializeHub();
    OMPlanets=stars.get(0).planets.size();
    longestDistance=round(stars.get(0).planets.get(OMPlanets-1).distance);
    longestDistance=longestDistance/100;
  }

  void initializeHub() { //Initializing Orbital Map data
  }

  /*void addDock() {
   if (dock==null) {
   dock=new OscDock[1];
   dock[0]=new OscDock(this, 0, new NetAddress(Settings.controllerIP[0], Settings.controllerInputPort[0]), Settings.oscInPort[0], ships[0]);
   } else {
   OscDock[] tempDocks=new OscDock[dock.length+1];
   for (int i=0; i<dock.length; i++) tempDocks[i]=dock[i];
   tempDocks[dock.length]=new OscDock(this, dock.length, new NetAddress(Settings.controllerIP[dock.length], Settings.controllerInputPort[dock.length]), Settings.oscInPort[dock.length], ships[dock.length]);
   dock=tempDocks;
   }
   }*/

  void update() { //
    for (OscDock d : dock) {
      OscBundle refreshBundle = new OscBundle(); 
      d.bundleLog.add("UBundle-C"+d.id+". Initial segment. Size: "+refreshBundle.size());
      if (frameCount%Settings.refreshInterval==d.refreshPhase) {      
        refreshBundle.add(new OscMessage("/OM/star").add(1));
        refreshBundle.add(new OscMessage("/OM/ship").add(1));
        refreshBundle.add(new OscMessage("/SC/directionIndicator").add(1));
        refreshBundle.add(new OscMessage("/OM/label35/visible").add(0));
        refreshBundle.add(new OscMessage("/FC/centreIndicator").add(1));
      }
      d.bundleLog.add("UBundle-C"+d.id+". Refresh segment. Size: "+refreshBundle.size());
      d.sendUpdates(refreshBundle);
    }
  }

  public void exit() {
    OscBundle exitBundle = new OscBundle();
    for (int i=dock.length-1; i>=0; i--) dock[i].exit(exitBundle);
  }
}

class OscDock {
  OscHub hub;
  OscP5 ex;
  Ship s;
  NetAddress c;
  int activePage=0;
  boolean activated=false;
  boolean unlocked=false;
  boolean cleared=false;
  boolean changeLandingButton=false;
  ArrayList<String> bundleLog;
  int id=0;
  int refreshPhase=0;
  int planetLocationUpdatePhase=0;
  int outPort;

  int SCturnWheelPosX=77+75; //Properties of the turn wheel
  int SCturnWheelPosY=20+65;
  int SCturnWheelRadius=55;
  int SCLEDCorrectionOffset=-10; //Offset ship direction LED by this ammount (they are drawn from top-left)
  boolean SCResetMissileControls=false; //Reset missile buttons after firing
  boolean SCUpdateWarpControls=false;   //Move warp fader and update label if warp speed changed
  boolean SCUpdateThrustControls=false; //Move thrust fader if thrust changed

  int OMCenterX=240; //Centre of the orbital map screen
  int OMCenterY=140;
  int[] OMPlanetDistances; //Distances between planets in touchOSC space

  int FCLEDScale=20; //Scale of the target LED
  int FCPadX=80; //Properties of the targeting pad
  int FCPadY=0;
  int FCPadRadius=110;
  int FCLEDCorrectionOffset=5; //Offset the target LED by this amount
  boolean FCFineTune=false; //Targeting fine tune
  boolean FCRecolorTuners=false; //Recolor tuners if fine tune state is changed
  float FCTGTX=0.5;
  float FCTGTY=0.5;

  OscDock() {
  }

  OscDock(OscHub _hub, int _id, NetAddress _c, int port, Ship _s) {
    hub=_hub;
    c=_c;
    s=_s;
    s.dock=this;
    id=_id;
    outPort=port;
    bundleLog=new ArrayList<String>();
    OMPlanetDistances=new int[hub.OMPlanets];
    for (int i=0; i<hub.OMPlanets; i++) OMPlanetDistances[i]=round(stars.get(0).planets.get(i).distance/hub.longestDistance);
    refreshPhase=Settings.refreshInterval/Settings.ships*id;
    planetLocationUpdatePhase=Settings.planetLocationUpdateInterval/Settings.ships*id;
  }

  OscDockInitialized initializeDock() {
    return (new OscDockInitialized(this));
  }
  void sendUpdates(OscBundle uB) {
  }
  public void displaceDirectionIndicator(OscBundle uB) {
  }
  void OMShipMove(OscBundle uB) {
  }
  void landingChange() {
  }
  void oscEvent(OscMessage theOscMessage) {
  }
  void lockScreenGreen(OscBundle b) {
  }
  void lockScreenClear(OscBundle b) {
  }
  void updateTargetBlip(OscBundle uB) {
  }
  void updateTargeters(OscBundle uB) {
  }
  void updateMissileControls(OscBundle uB) {
  }
  void updateWarpControls(OscBundle uB) {
  }
  void updateThrustControls(OscBundle uB) {
  }
  void send(OscBundle b) {
  }
  void send(OscMessage m) {
  }
  public void exit(OscBundle eB) {
  }
  void plugs() {
  }
  public void changeThrottle(float f) {
  }
  public void warp(float f) {
  }
  public void turnLeft(float f) {
  }
  public void turnRight(float f) {
  }
  public void enterPlanet(float f) {
  }
  public void turnTo(float f) {
  }
  public void lockMissile(float f) {
  }
  public void fireMissile(float f) {
  }
  public void changeWarpSpeed(float f) {
  }
  public void moveCursor(float x, float y) {
  }
  public void placeVolcano(float f) {
  }
  public void heightView(float f) {
  }
  public void changeZoom(float f) {
  }
  public void shoot(float f) {
  }
  public void changeAim(float x, float y) {
  }
  public void fineTuneX(float f) {
  }
  public void fineTuneY(float f) {
  }
  public void switchFineTune(float f) {
  }
  public void switchToSC() {
  }
  public void switchToPV() {
  }
  public void switchToOM() {
  }
  public void switchToFC() {
  }  
  public void unlock(float f) {
  }
  public void isIP4(float f) {
  }
  public void isIP5(float f) {
  }
}

class OscDockInitialized extends OscDock {
  OscDockInitialized(OscDock buildOn) {
    super(buildOn.hub, buildOn.id, buildOn.c, buildOn.outPort, buildOn.s);
    ex=new OscP5(this, outPort);
    plugs();
    OscBundle startBundle = new OscBundle();
    startBundle.add(new OscMessage("/vibrate"));
    startBundle.setTimetag(startBundle.now());
    bundleLog.add("StartBundle-C"+id+". Size: "+startBundle.size());
    lockScreenGreen(startBundle);
    send(startBundle);
  }

  void lockScreenGreen(OscBundle b) {
      b.add(new OscMessage("/SC"));
      b.add(new OscMessage("/SC/connectionStatus/visible").add(1));
      b.add(new OscMessage("/SC/connectionStatus").add("Connection established"));
      b.add(new OscMessage("/SC/connectionStatus/color").add("green"));
      b.add(new OscMessage("/SC/screenBlock/visible").add(1));
      b.add(new OscMessage("/SC/screenBlockIP5/visible").add(1));
      b.add(new OscMessage("/SC/screenBlock/color").add("green"));
      b.add(new OscMessage("/SC/screenBlockIP5/color").add("green"));
      b.add(new OscMessage("/SC/tapHint/visible").add(1));
      b.add(new OscMessage("/SC/tapHint/position/y").add(202));
      bundleLog.add("UBundle-C"+id+". Lock screen update segment. Size: "+b.size());
  }

  void lockScreenClear(OscBundle b) {
    cleared=true;
    b.add(new OscMessage("/SC/connectionStatus/visible").add(0));
    b.add(new OscMessage("/SC/screenBlock/visible").add(0));
    b.add(new OscMessage("/SC/screenBlockIP5/visible").add(0));
    b.add(new OscMessage("/SC/tapHint/visible").add(0));
    b.add(new OscMessage("/SC/label41/color").add("green"));
    b.add(new OscMessage("/SC/lockLabel").add("Lock target"));
    b.add(new OscMessage("/SC/lockMissile").add(0));
    b.add(new OscMessage("/SC/fireLabel").add("No lock"));
    b.add(new OscMessage("/SC/fireLabel/color").add("gray"));
    s.missileAiming=false;
    b.add(new OscMessage("/SC/label41/color").add("green"));
    b.add(new OscMessage("/SC/label41/color").add("gray"));
    b.add(new OscMessage("/SC/directionIndicator").add(1));   
    b.add(new OscMessage("/SC/warpSpeedLabel").add(Settings.minWarpSpeed));   
    b.add(new OscMessage("/SC/warpSpeed").add(0));   
    b.add(new OscMessage("/SC/throttle").add(0));   
    b.add(new OscMessage("/OM/star").add(1));     
    b.add(new OscMessage("/OM/ship").add(1));     
    b.add(new OscMessage("/OM/label35/visible").add(0));     
    for (int i=0; i<hub.OMPlanets; i++) b.add(new OscMessage("/OM/planet"+i).add(1));     
    for (int i=hub.OMPlanets; i<Settings.maxPlanetsPerStar; i++) b.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
    b.add(new OscMessage("/OM/zoom").add(0.88));
    b.add(new OscMessage("/FC/targeter/x").add(FCTGTX));
    b.add(new OscMessage("/FC/targeter/y").add(FCTGTY));
    b.add(new OscMessage("/FC/fineX").add(FCTGTX));
    b.add(new OscMessage("/FC/fineY").add(FCTGTY));
    b.add(new OscMessage("/FC/fineTune").add(0));
    b.add(new OscMessage("/FC/fineX/color").add("yellow"));
    b.add(new OscMessage("/FC/fineY/color").add("yellow"));
    b.add(new OscMessage("/FC/targeter/color").add("yellow"));
    bundleLog.add("UBundle-C"+id+". Lock screen clearer segment. Size: "+b.size());
  }

  void sendUpdates(OscBundle uB) {
    if (!activated) lockScreenGreen(uB);
    else
    {
      if (unlocked) {
        if (!cleared) lockScreenClear(uB);
        if (activePage==0) {
          displaceDirectionIndicator(uB);
          updateMissileControls(uB);
          if (SCUpdateWarpControls) updateWarpControls(uB);
          if (SCUpdateThrustControls) updateThrustControls(uB);
        }
        if (activePage==2) {
          for (int i=0; i<hub.OMPlanets; i++) uB.add(new OscMessage("/OM/planet"+i).add(1));
          for (int i=hub.OMPlanets; i<Settings.maxPlanetsPerStar; i++) uB.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
          for (int i=0; i<hub.OMPlanets; i++) OMPlanetMove(uB, i);
          OMShipMove(uB);
        }
        if (activePage==3) {
          updateTargetBlip(uB);
          updateTargeters(uB);
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

  void OMPlanetMove(OscBundle outBundle, int targetPlanetIndex) {
    if (frameCount%Settings.planetLocationUpdateInterval==planetLocationUpdatePhase) {
      int OMPlanetPosX=round(stars.get(0).planets.get(targetPlanetIndex).pos.x/hub.longestDistance+OMCenterX+hub.OMLEDCorrectionOffset);
      outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/x").add(OMPlanetPosX));
      int OMPlanetPosY=round(stars.get(0).planets.get(targetPlanetIndex).pos.y/hub.longestDistance+OMCenterY+hub.OMLEDCorrectionOffset);
      outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/y").add(OMPlanetPosY));
    }
    bundleLog.add("UBundle-C"+id+". Planet position segment. Size: "+outBundle.size());
  }

  public void displaceDirectionIndicator(OscBundle uB) { //Don't use alone! Adds to bundle
    uB.add(new OscMessage("/SC/directionIndicator/position/x").add(SCLEDCorrectionOffset+round(SCturnWheelPosX+SCturnWheelRadius+SCturnWheelRadius*cos(s.dir))));
    uB.add(new OscMessage("/SC/directionIndicator/position/y").add(SCLEDCorrectionOffset+round(SCturnWheelPosY+SCturnWheelRadius+SCturnWheelRadius*sin(s.dir))));
    bundleLog.add("UBundle-C"+id+". DI segment. Size: "+uB.size());
  }

  void OMShipMove(OscBundle uB) { //Don't use alone! Adds to bundle
    int OMShipPosX=round(s.pos.x/hub.longestDistance+OMCenterX+hub.OMLEDCorrectionOffset);
    if (OMShipPosX>round(OMCenterX*1.9)) OMShipPosX=round(OMCenterX*1.9);
    else if (OMShipPosX<0) OMShipPosX=0;
    int OMShipPosY=round(s.pos.y/hub.longestDistance+OMCenterY+hub.OMLEDCorrectionOffset);
    if (OMShipPosY>round(OMCenterY*1.9)) OMShipPosY=round(OMCenterY*1.9); 
    else if (OMShipPosY<0) OMShipPosY=0;
    uB.add(new OscMessage("/OM/ship/position/x").add(OMShipPosX));
    uB.add(new OscMessage("/OM/ship/position/y").add(OMShipPosY));
  }

  void landingChange() {
    changeLandingButton=!changeLandingButton;
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

  void updateTargetBlip(OscBundle uB) {
    if (s.distToTarget<Settings.targetingDistance)
    {
      float quad=1-s.distToTarget/Settings.targetingDistance;
      float scale=FCLEDScale*(quad*quad);
      float targetDir=atan2(s.target.pos.y-s.pos.y, s.target.pos.x-s.pos.x);
      uB.add(new OscMessage("/FC/hostileBlip/position/x").add(FCLEDCorrectionOffset+round(FCPadX+FCPadRadius+FCPadRadius*cos(targetDir)*(1-quad))));
      uB.add(new OscMessage("/FC/hostileBlip/position/y").add(FCLEDCorrectionOffset+round(FCPadY+FCPadRadius+FCPadRadius*sin(targetDir)*(1-quad))));
      uB.add(new OscMessage("/FC/hostileBlip/size/w").add(scale));
      uB.add(new OscMessage("/FC/hostileBlip/size/h").add(scale));
      uB.add(new OscMessage("/FC/hostileBlip/").add(quad));
    } else {
      uB.add(new OscMessage("/FC/hostileBlip/position/x").add(-20));
      uB.add(new OscMessage("/FC/hostileBlip/position/y").add(0));
    }
    bundleLog.add("UBundle-C"+id+". Targeting segment. Size: "+uB.size());
  }

  void updateTargeters(OscBundle uB) {
    if (FCFineTune) {
      uB.add(new OscMessage("/FC/targeter/x").add(FCTGTX));
      uB.add(new OscMessage("/FC/targeter/y").add(FCTGTY));
    } else {
      uB.add(new OscMessage("/FC/fineX").add(FCTGTX));
      uB.add(new OscMessage("/FC/fineY").add(FCTGTY));
    }
    if (FCRecolorTuners)
      if (FCFineTune) {
        uB.add(new OscMessage("/FC/fineX/color").add("gray"));
        uB.add(new OscMessage("/FC/fineY/color").add("gray"));
        uB.add(new OscMessage("/FC/targeter/color").add("gray"));
        FCRecolorTuners=false;
      } else
      {
        uB.add(new OscMessage("/FC/fineX/color").add("yellow"));
        uB.add(new OscMessage("/FC/fineY/color").add("yellow"));
        uB.add(new OscMessage("/FC/targeter/color").add("yellow"));
        FCRecolorTuners=false;
      }
  }

  void updateMissileControls(OscBundle uB) {
    if (SCResetMissileControls) {
      uB.add(new OscMessage("/SC/lockLabel").add("Lock target"));
      uB.add(new OscMessage("/SC/lockMissile").add(0));
      uB.add(new OscMessage("/SC/fireLabel").add("No lock"));
      uB.add(new OscMessage("/SC/fireLabel/color").add("gray"));
      SCResetMissileControls=false;
    }
    if (s.missileAiming) {
      if (s.target!=null) {
        if (s.mssls>0) {
          uB.add(new OscMessage("/SC/fireLabel").add("FIRE"));
          uB.add(new OscMessage("/SC/fireLabel/color").add("red"));
        } else
        {
          uB.add(new OscMessage("/SC/fireLabel").add("No missiles"));
          uB.add(new OscMessage("/SC/fireLabel/color").add("gray"));
        }
      } else
      {
        uB.add(new OscMessage("/SC/fireLabel").add("No target"));
        uB.add(new OscMessage("/SC/fireLabel/color").add("gray"));
      }
    } else
    {
      uB.add(new OscMessage("/SC/fireLabel").add("No lock"));
      uB.add(new OscMessage("/SC/fireLabel/color").add("gray"));
    }
    bundleLog.add("UBundle-C"+id+". Missile control segment. Size: "+uB.size());
  }

  void updateWarpControls(OscBundle uB) {
    uB.add(new OscMessage("/SC/warpSpeedLabel").add((int)s.warpSpeed));
    uB.add(new OscMessage("/SC/warpSpeed").add((s.warpSpeed-Settings.minWarpSpeed)/(Settings.maxWarpSpeed-Settings.minWarpSpeed)));
    SCUpdateWarpControls=false;
    bundleLog.add("UBundle-C"+id+". Warp speed label segment. Size: "+uB.size());
  }

  void updateThrustControls(OscBundle uB) {
    uB.add(new OscMessage("/SC/throttle").add(s.thrust));
    SCUpdateThrustControls=false;
    bundleLog.add("UBundle-C"+id+". Throttle segment. Size: "+uB.size());
  }

  void send(OscBundle b) {
    bundleLog.add("UBundle-C"+id+". Sending... Size: "+b.size());
    if (Settings.displayOSCBundleLogs) for (String s : bundleLog) println(s);
    bundleLog.clear();
    if (b.size()>0) {
      b.setTimetag(b.now());
      ex.send(b, c);
    }
  }

  void send(OscMessage m) {
    ex.send(m, c);
  }

  public void exit(OscBundle eB) {
    eB.add(new OscMessage("/OM/star").add(0));     
    eB.add(new OscMessage("/OM/ship").add(0));     
    eB.add(new OscMessage("/SC/directionIndicator").add(0));     
    eB.add(new OscMessage("/OM/label35/visible").add(1));     
    for (int i=0; i<hub.OMPlanets; i++) eB.add(new OscMessage("/OM/planet"+i).add(0));
    ex.dispose();
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
    ex.plug(this, "lockMissile", "/SC/lockMissile");
    ex.plug(this, "fireMissile", "/SC/fireMissile");
    ex.plug(this, "changeWarpSpeed", "/SC/warpSpeed");
    ex.plug(this, "moveCursor", "/PV/locator");
    ex.plug(this, "placeVolcano", "/PV/placeVolcano");
    ex.plug(this, "heightView", "/PV/heightView");
    ex.plug(this, "changeZoom", "/OM/zoom");
    ex.plug(this, "shoot", "/FC/fire");
    ex.plug(this, "changeAim", "/FC/targeter");
    ex.plug(this, "fineTuneX", "/FC/fineX");
    ex.plug(this, "fineTuneY", "/FC/fineY");
    ex.plug(this, "switchFineTune", "/FC/fineTune");
    ex.plug(this, "switchToSC", "/SC");
    ex.plug(this, "switchToPV", "/PV");
    ex.plug(this, "switchToOM", "/OM");
    ex.plug(this, "switchToFC", "/FC");
    //ex.plug(this, "unlock", "/SC/screenBlock");
    //ex.plug(this, "unlock", "/SC/screenBlockIP5");
    ex.plug(this, "isIP4", "/SC/screenBlock");
    ex.plug(this, "isIP5", "/SC/screenBlockIP5");
  }

  public void changeThrottle(float f) {
    s.thrust=f;
  }
  public void warp(float f) {
    if (s.warp) s.stopWarp();
    else s.warp=true;
  }
  public void turnLeft(float f) {
    if (!s.warp) if (f==0) s.turnLeft=false;
    else s.turnLeft=true;
  }
  public void turnRight(float f) {
    if (!s.warp) if (f==0) s.turnRight=false;
    else s.turnRight=true;
  }

  public void enterPlanet(float f) {
    if (s.displayPlanetMap==true)  
    {
      s.displayPlanetMap=false;
      active=null;
    } else if (s.land!=null) {
      s.displayPlanetMap=true;
      s.thrust=0;
      ex.send(new OscMessage("/PV"));
    }
  }

  public void turnTo(float f) {
    if (!s.warp)
      if (f>0) {
        s.turnWheelInput++; 
        s.turnRight=true;
        s.turnRight(0.1);
        s.turnLeft=false;
      } else if (f<0) {
        s.turnWheelInput++; 
        s.turnLeft=true;
        s.turnLeft(0.1);
        s.turnRight=false;
      } //s.spin+=(s.thrust*Settings.assistedTurnSpeed+Settings.staticTurnSpeed)*f*2;
  }

  public void lockMissile(float f) {
    if (f==0)s.missileAiming=false;
    else s.missileAiming=true;
  }

  public void fireMissile(float f) {
    if (s.missileAiming) {
      s.fireMissile();
      s.missileAiming=false;
      SCResetMissileControls=true;
    }
  }

  public void changeWarpSpeed(float f) {
    //if (!s.warp) 
    s.warpSpeed=Settings.minWarpSpeed+f*(Settings.maxWarpSpeed-Settings.minWarpSpeed);
    SCUpdateWarpControls=true;
  }

  public void moveCursor(float x, float y)
  {
    if (s.land!=null) {
      int xOffset=(width-s.land.surface.width)/2;
      int yOffset=(height-s.land.surface.height)/2;
      cursor.x=xOffset+x*ships[0].land.surface.width;
      cursor.y=yOffset+y*ships[0].land.surface.height;
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
    s.zoom=0.2+48.8*(1-f)*(1-f);
  }

  public void shoot(float f) {
    s.shoot();
  }

  public void changeAim(float x, float y)
  {
    if (!FCFineTune) {
      FCTGTX=x;
      FCTGTY=y;
      s.aimDir=atan2(y-0.5, x-0.5)-HALF_PI;
    }
  }

  public void fineTuneX(float f) {
    if (FCFineTune) {
      FCTGTX=f;
      s.aimDir=atan2(FCTGTY-0.5, f-0.5)-HALF_PI;
    }
  }

  public void fineTuneY(float f) {
    if (FCFineTune) {
      FCTGTY=f;
      s.aimDir=atan2(f-0.5, FCTGTX-0.5)-HALF_PI;
    }
  }

  public void switchFineTune(float f) {
    if (f==0) FCFineTune=false;
    else FCFineTune=true;
    FCRecolorTuners=true;
  }

  public void switchToSC() {
    activePage=0;
  }

  public void switchToPV() {
    activePage=1;
  }

  public void switchToOM() {
    activePage=2;
  }

  public void switchToFC() {
    activePage=3;
  }

  //public void unlock(float f) {

  //}
  public void isIP4(float f) {
    unlocked=true;
  }
  public void isIP5(float f) {
    unlocked=true;
    SCturnWheelPosX=172;
    OMCenterX=284;
    FCPadX=140; //Properties of the targeting pad
    println("poot");
  }
}
