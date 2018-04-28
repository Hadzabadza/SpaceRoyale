void startOSC(int port) {
  oscP5 = new OscP5(this, port);
  controller = new NetAddress("127.0.0.1", 12000);
  OSCplugs();
}

void startOSC(int port, String outIP, int outPort) {
  oscP5 = new OscP5(this, port);
  controller = new NetAddress(outIP, outPort);
  OSCplugs();
}

void OSCplugs() {
  oscP5.plug(this, "changeThrottle", "/SC/throttle");
  oscP5.plug(this, "warp", "/SC/warp");
  oscP5.plug(this, "turnLeft", "/SC/turnLeft");
  oscP5.plug(this, "turnRight", "/SC/turnRight");
  oscP5.plug(this, "enterPlanet", "/SC/planetView");
  oscP5.plug(this, "turnTo", "/SC/turnWheel");
  oscP5.plug(this, "moveCursor", "/PV/locator");
  oscP5.plug(this, "placeVolcano", "/PV/placeVolcano");
  oscP5.plug(this, "heightView", "/PV/heightView");
}

void OSCtoggle(){
    /* in the following different ways of creating osc messages are shown by example 
  OscMessage myMessage = new OscMessage("/test");
  myMessage.setAddrPattern("/SC/TurnWheel");
  myMessage.add(1);  add an int to the osc message */

; /* add an int to the osc message */
  /* send the message */
  //oscP5.send(myMessage, controller); 
}
/*void oscEvent(OscMessage theOscMessage) {
 // print the address pattern and the typetag of the received OscMessage 
 print("### received an osc message.");
 print(" addrpattern: "+theOscMessage.addrPattern());
 println(" typetag: "+theOscMessage.typetag());
 }*/

public void changeThrottle(float f) {
  ship.thrust=f;
}
public void warp(float f) {
  ship.warp=!ship.warp;
}
public void turnLeft(float f) {
  if (f==0) move[1]=false;
  else move[1]=true;
}
public void turnRight(float f) {
  if (f==0) move[3]=false;
  else move[3]=true;
}

public void enterPlanet(float f) {
  if (mapScreen==true)  
  {
    mapScreen=false;
    active=null;
  } else if (ship.land!=null) {
    mapScreen=true;
    ship.thrust=0;
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