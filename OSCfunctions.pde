//TODO: stop sending orbital data when OM page is not active

class Osc {
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

  Osc(int port) {
    oscP5 = new OscP5(this, port);
    controller = new NetAddress("127.0.0.1", 12000);
    OMStart();
    plugs();
  }

  Osc(int port, String outIP, int outPort) {
    oscP5 = new OscP5(this, port);
    controller = new NetAddress(outIP, outPort);
    OMStart();
    plugs();
  }

  void plugs() {
    oscP5.plug(this, "changeThrottle", "/SC/throttle");
    oscP5.plug(this, "warp", "/SC/warp");
    oscP5.plug(this, "turnLeft", "/SC/turnLeft");
    oscP5.plug(this, "turnRight", "/SC/turnRight");
    oscP5.plug(this, "enterPlanet", "/SC/planetView");
    oscP5.plug(this, "turnTo", "/SC/turnWheel");
    oscP5.plug(this, "moveCursor", "/PV/locator");
    oscP5.plug(this, "placeVolcano", "/PV/placeVolcano");
    oscP5.plug(this, "heightView", "/PV/heightView");
    oscP5.plug(this, "changeZoom", "/OM/zoom");
    oscP5.plug(this, "shoot", "/FC/fire");
    oscP5.plug(this, "changeAim", "/FC/targeter");
    oscP5.plug(this, "pageSwitch", "/SC");
    oscP5.plug(this, "pageSwitch", "/PV");
    oscP5.plug(this, "pageSwitch", "/OM");
  }

  void OMStart() { //Startup of orbital map page
    OMPlanets=planets.size();
    OMPlanetDistances=new int[OMPlanets];
    longestDistance=round(planets.get(OMPlanets-1).distance);
    longestDistance=longestDistance/100;
    for (int i=0; i<OMPlanets; i++)
    {
      OMPlanetDistances[i]=round(planets.get(i).distance/longestDistance);
    }

    /* create an osc bundle */
    OscBundle myBundle = new OscBundle();

    myBundle.add(new OscMessage("/OM/star").add(1));     
    myBundle.add(new OscMessage("/OM/ship").add(1));     
    myBundle.add(new OscMessage("/SC/directionIndicator").add(1));     
    myBundle.add(new OscMessage("/OM/label35/visible").add(0));     
    for (int i=0; i<OMPlanets; i++) {
      myBundle.add(new OscMessage("/OM/planet"+i).add(1));
    }     
    for (int i=OMPlanets; i<maxPlanetsPerStar; i++)
    {
      myBundle.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
    }
    myBundle.add(new OscMessage("/OM/zoom").add(0.84));
    myBundle.setTimetag(myBundle.now());
    oscP5.send(myBundle, controller);
  }

  void OMUpdate() {
    OscBundle myBundle = new OscBundle();    
    if (frameCount%120==0) {      
      myBundle.add(new OscMessage("/OM/star").add(1));
      myBundle.add(new OscMessage("/OM/ship").add(1));
      myBundle.add(new OscMessage("/SC/directionIndicator").add(1));
      myBundle.add(new OscMessage("/OM/label35/visible").add(0));
      myBundle.add(new OscMessage("/FC/centreIndicator").add(1));
      for (int i=0; i<OMPlanets; i++) {
        myBundle.add(new OscMessage("/OM/planet"+i).add(1));
      }
      for (int i=OMPlanets; i<maxPlanetsPerStar; i++)
      {
        myBundle.add(new OscMessage("/OM/planet"+i+"/position/x").add(-30));
      }
    }
    displaceDIndicator();
    for (int i=0; i<OMPlanets; i++) {
      OMPlanetMove(myBundle, i);
    }
    if (ship.land!=null) {
      myBundle.add(new OscMessage("/SC/planetView/color").add("green"));
    } else
    {
      myBundle.add(new OscMessage("/SC/planetView/color").add("gray"));
    }
    OMShipMove(myBundle);
    myBundle.setTimetag(myBundle.now());
    /* send the osc bundle, containing 2 osc messages, to a remote location. */
    oscP5.send(myBundle, controller);
  }

  void OMPlanetMove(OscBundle outBundle, int targetPlanetIndex) {
    int OMPlanetPosX=round(planets.get(targetPlanetIndex).pos.x/longestDistance+OMCenterX+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/x").add(OMPlanetPosX));
    int OMPlanetPosY=round(planets.get(targetPlanetIndex).pos.y/longestDistance+OMCenterY+OMCorrectionOffset);
    outBundle.add(new OscMessage("/OM/planet"+targetPlanetIndex+"/position/y").add(OMPlanetPosY));
  }

  void OMShipMove(OscBundle outBundle) { //Don't use alone! Needs the bundle sent at some point after use
    OscMessage myMessage;
    myMessage = new OscMessage("/OM/ship/position/x");
    int OMShipPosX=round(ship.pos.x/longestDistance+OMCenterX+OMCorrectionOffset);
    if (OMShipPosX>OMCenterX*2) {
      OMShipPosX=OMCenterX*2;
    } else
    {
      if (OMShipPosX<0) {
        OMShipPosX=0;
      }
    }
    myMessage.add(OMShipPosX);
    outBundle.add(myMessage);
    myMessage.clear();

    myMessage = new OscMessage("/OM/ship/position/y");
    int OMShipPosY=round(ship.pos.y/longestDistance+OMCenterY+OMCorrectionOffset);
    if (OMShipPosY>OMCenterY*2) {
      OMShipPosY=OMCenterY*2;
    } else
    {
      if (OMShipPosY<0) {
        OMShipPosY=0;
      }
    }
    myMessage.add(OMShipPosY);
    outBundle.add(myMessage);
    myMessage.clear();
    outBundle.add(myMessage);
  }

  public void changeThrottle(float f) {
    ship.thrust=f;
  }
  public void warp(float f) {
    ship.warp=!ship.warp;
  }
  public void turnLeft(float f) {
    if (f==0) input[1]=false;
    else {
      input[1]=true;
      displaceDIndicator();
    }
  }
  public void turnRight(float f) {
    if (f==0) input[3]=false;
    else {
      input[3]=true;
      displaceDIndicator();
    }
  }

  public void changeZoom(float f) {
    zoom=0.8+9.2*(1-f)*(1-f);
  }

  public void shoot(float f) {
    ship.shoot();
  }

  public void changeAim(float x, float y)
  {
    x-=0.5;
    y-=0.5;
    ship.aimDir=degrees(atan2(y, x))-90;
  }

  public void displaceDIndicator() {
    OscBundle dIndicBundle=new OscBundle();
    OscMessage dIndicMessage=new OscMessage("/SC/directionIndicator/position/x");
    dIndicMessage.add(OMCorrectionOffset+round(turnWheelPosX+turnWheelRadius+turnWheelRadius*cos(radians(ship.dir))));
    dIndicBundle.add(dIndicMessage);
    dIndicMessage.clear();
    dIndicMessage=new OscMessage("/SC/directionIndicator/position/y");
    dIndicMessage.add(OMCorrectionOffset+round(turnWheelPosY+turnWheelRadius+turnWheelRadius*sin(radians(ship.dir))));
    dIndicBundle.add(dIndicMessage);
    dIndicBundle.setTimetag(dIndicBundle.now());
    oscP5.send(dIndicBundle, controller);
  }

  public void enterPlanet(float f) {
    if (mapScreen==true)  
    {
      mapScreen=false;
      active=null;
    } else if (ship.land!=null) {
      mapScreen=true;
      ship.thrust=0;
      oscP5.send(new OscMessage("/PV"), controller);
    }
  }

  public void turnTo(float f) {
    ship.dir+=(ship.thrust+1)*f;
  }

  public void moveCursor(float x, float y)
  {
    if (ship.land!=null) {
      int xOffset=(width-ship.land.map.width)/2;
      int yOffset=(height-ship.land.map.height)/2;
      cursor.x=xOffset+x*ship.land.map.width;
      cursor.y=yOffset+y*ship.land.map.height;
    }
  }

  public void heightView(float f)
  {
    heightColour=!heightColour;
  }

  public void placeVolcano(float f) {
    if (ship.land!=null) {
      Terrain t=ship.land.pickTile();
      if (t!=null)
      {
        t.volcanize();
      }
    }
  }

  /*void oscEvent(OscMessage theOscMessage) {
   // print the address pattern and the typetag of the received OscMessage 
   print("### received an osc message.");
   print(" addrpattern: "+theOscMessage.addrPattern());
   println(" typetag: "+theOscMessage.typetag());
   }*/

  void oscTest() {
    /* in the following different ways of creating osc messages are shown by example 
     OscMessage myMessage = new OscMessage("/test");
     myMessage.setAddrPattern("/SC/TurnWheel");
     myMessage.add(1);  add an int to the osc message */

    ; /* add an int to the osc message */
    /* send the message */
    //oscP5.send(myMessage, controller);
  }
}