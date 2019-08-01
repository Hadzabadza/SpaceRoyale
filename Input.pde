void keyPressed() { 
  if (!ships[0].displayPlanetMap) {
    if ((key == 'w')||(key=='W'))  ships[0].speedUp = true;
    if ((key == 's')||(key=='S'))  ships[0].slowDown = true;
    if ((key == 'a')||(key=='A'))  ships[0].turnLeft = true;
    if ((key == 'd')||(key=='D'))  ships[0].turnRight = true;
    if ((key == 'r')||(key=='R'))  ships[0].incWarpSpeed = true;
    if ((key == 'f')||(key=='F'))  ships[0].decWarpSpeed = true;
    if ((key == 'q')||(key=='Q'))  ships[0].turnTurretLeft = true;
    if ((key == 'e')||(key=='E'))  ships[0].turnTurretRight = true;
    if (key == ' ')  ships[0].fire = true;
    if ((key == 'c')||(key=='C')) ships[0].afterBurning=true;
    if ((key == 'z')||(key=='Z')) ships[0].missileAiming=true;
  }
  if (ships.length>1&&!ships[1].displayPlanetMap) {
    if ((keyCode==UP)||(key==56))  ships[1].speedUp = true;
    if ((keyCode==DOWN)||(key==50))  ships[1].slowDown = true;
    if ((keyCode==LEFT)||(key==52))  ships[1].turnLeft = true;
    if ((keyCode==RIGHT)||(key==54)) ships[1].turnRight = true;
    if (key == 51)  ships[1].incWarpSpeed = true;
    if (key == 49)  ships[1].decWarpSpeed = true;
    if (key == 55)  ships[1].turnTurretLeft = true;
    if (key == 57)  ships[1].turnTurretRight = true;
    if (key == 48)  ships[1].fire = true;
    if (key == 45)  ships[1].zoomOut = true;
    if (key == 43)  ships[1].zoomIn = true;
    if (key==53) ships[1].missileAiming=true;
  }
}

void keyReleased() {
  if ((key == 'o')||(key=='O')) Settings.DEBUG=!Settings.DEBUG;
  if (Settings.DEBUG) {
    if ((key == 'p')||(key=='P')) Settings.drawObjectsOnlyInRange=!Settings.drawObjectsOnlyInRange;
  }
  if ((keyCode==ENTER)||(keyCode==RETURN)) init();
  if (!ships[0].displayPlanetMap) {
    if ((key == 'w')||(key=='W'))  ships[0].speedUp = false;
    if ((key == 's')||(key=='S'))  ships[0].slowDown = false;
    if ((key == 'a')||(key=='A'))  ships[0].turnLeft = false;
    if ((key == 'd')||(key=='D'))  ships[0].turnRight = false;
    if ((key == 'r')||(key=='R'))  ships[0].incWarpSpeed = false;
    if ((key == 'f')||(key=='F'))  ships[0].decWarpSpeed = false;
    if ((key == 'q')||(key=='Q'))  ships[0].turnTurretLeft = false;
    if ((key == 'e')||(key=='E'))  ships[0].turnTurretRight = false;
    if (key == ' ')  ships[0].fire = false;
    if ((key == 'c')||(key=='C')) ships[0].afterBurning=false;
    if ((key == 'x')||(key=='X'))  if (ships[0].warp) ships[0].stopWarp(); 
    else ships[0].warp=true;
    if ((key == 'z')||(key=='Z')) {
      ships[0].fireMissile();
      ships[0].missileAiming=false;
    }
  }
  if (ships.length>1&&!ships[1].displayPlanetMap) {
    if ((keyCode==UP)||(key==56))  ships[1].speedUp = false;
    if ((keyCode==DOWN)||(key==50))  ships[1].slowDown = false;
    if ((keyCode==LEFT)||(key==52))  ships[1].turnLeft = false;
    if ((keyCode==RIGHT)||(key==54)) ships[1].turnRight = false;
    if (key == 51)  ships[1].incWarpSpeed = false;
    if (key == 49)  ships[1].decWarpSpeed = false;
    if (key == 55)  ships[1].turnTurretLeft = false;
    if (key == 57)  ships[1].turnTurretRight = false;
    if (key == 48)  ships[1].fire = false;
    if (key == 46)  if (ships[1].warp) ships[1].stopWarp(); 
    else ships[1].warp=true;
    if (key==53) {
      ships[1].fireMissile();
      ships[1].missileAiming=false;
    }
    if (key == 45)  ships[1].zoomOut = false;
    if (key == 43)  ships[1].zoomIn = false;
  }
}

void mouseWheel(MouseEvent e) {
  if (e.getCount()>0) ships[0].zoomOut();
  else ships[0].zoomIn();
}


void mouseReleased() {
  if (mouseButton==RIGHT) if (ships[0].displayPlanetMap) heightColour=!heightColour;
  if (mouseButton==LEFT)
  {
    if (ships[0].displayPlanetMap) 
    {
      Terrain t=ships[0].land.pickTile();
      if (t!=null)
      {
        t.build();
        t.volcanize();
      }
      if (t==null)
      {
        ships[0].displayPlanetMap=false;
        ships[0].land.updateSurfaceImagery();
        active=null;
      }
    } else if (ships[0].land!=null) {
      ships[0].displayPlanetMap=true;
      ships[0].thrust=0;
    }
  }
  if (mouseButton==CENTER) if (ships[0].displayPlanetMap) {
    Terrain t=ships[0].land.pickTile();
    if (t!=null) t.plopLava();
    else ships[0].zoom=1;
  } else ships[0].zoom=1;
}

void mouseMoved() {
  cursor.x=mouseX;
  cursor.y=mouseY;
}
