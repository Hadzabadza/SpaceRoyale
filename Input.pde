void keyPressed() { 
  if (!mapScreen) {
    if ((key == 'w')||(key=='W'))  ships[0].speedUp = true;
    if ((key == 's')||(key=='S'))  ships[0].slowDown = true;
    if ((key == 'a')||(key=='A'))  ships[0].turnLeft = true;
    if ((key == 'd')||(key=='D'))  ships[0].turnRight = true;
    if ((key == 'q')||(key=='Q'))  ships[0].turnTurretLeft = true;
    if ((key == 'e')||(key=='E'))  ships[0].turnTurretRight = true;
    if (key == ' ')  ships[0].fire = true;

    if ((keyCode==UP)||(key==56))  ships[1].speedUp = true;
    if ((keyCode==DOWN)||(key==50))  ships[1].slowDown = true;
    if ((keyCode==LEFT)||(key==52))  ships[1].turnLeft = true;
    if ((keyCode==RIGHT)||(key==54)) ships[1].turnRight = true;
    if (key == 55)  ships[1].turnTurretLeft = true;
    if (key == 57)  ships[1].turnTurretRight = true;
    if (key == 48)  ships[1].fire = true;
    if (key == 45)  ships[1].zoomOut = true;
    if (key == 43)  ships[1].zoomIn = true;
  }
}

void keyReleased() {
  if ((key=='r')||(key=='R')) init();
  if (!mapScreen) {
    if ((key == 'w')||(key=='W'))  ships[0].speedUp = false;
    if ((key == 's')||(key=='S'))  ships[0].slowDown = false;
    if ((key == 'a')||(key=='A'))  ships[0].turnLeft = false;
    if ((key == 'd')||(key=='D'))  ships[0].turnRight = false;
    if ((key == 'q')||(key=='Q'))  ships[0].turnTurretLeft = false;
    if ((key == 'e')||(key=='E'))  ships[0].turnTurretRight = false;
    if (key == ' ')  ships[0].fire = false;
    if ((key == 'x')||(key=='X'))  ships[0].warp = !ships[0].warp;

    if ((keyCode==UP)||(key==56))  ships[1].speedUp = false;
    if ((keyCode==DOWN)||(key==50))  ships[1].slowDown = false;
    if ((keyCode==LEFT)||(key==52))  ships[1].turnLeft = false;
    if ((keyCode==RIGHT)||(key==54)) ships[1].turnRight = false;
    if (key == 55)  ships[1].turnTurretLeft = false;
    if (key == 57)  ships[1].turnTurretRight = false;
    if (key == 48)  ships[1].fire = false;
    if (key == 46)  ships[1].warp = !ships[1].warp;
    if (key == 45)  ships[1].zoomOut = false;
    if (key == 43)  ships[1].zoomIn = false;
  }
}

void mouseWheel(MouseEvent e) {
  if (e.getCount()>0) ships[0].zoomOut();
  else ships[0].zoomIn();
}


void mouseReleased() {
  if (mouseButton==RIGHT) if (mapScreen) heightColour=!heightColour;
  if (mouseButton==LEFT)
  {
    if (mapScreen) 
    {
      Terrain t=ships[0].land.pickTile();
      if (t!=null)
      {
        t.build();
        t.volcanize();
      }
      if (t==null)
      {
        mapScreen=false;
        active=null;
      }
    } else if (ships[0].land!=null) {
      mapScreen=true;
      ships[0].thrust=0;
    }
  }
  if (mouseButton==CENTER) ships[0].zoom=1;
}

void mouseMoved() {
  cursor.x=mouseX;
  cursor.y=mouseY;
}