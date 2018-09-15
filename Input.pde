void keyPressed() { 
  println (int(key));
  if (!mapScreen) {
    if ((key == 'w')||(key=='W'))  ships.get(0).speedUp = true;
    if ((key == 's')||(key=='S'))  ships.get(0).slowDown = true;
    if ((key == 'a')||(key=='A'))  ships.get(0).turnLeft = true;
    if ((key == 'd')||(key=='D'))  ships.get(0).turnRight = true;
    if ((key == 'q')||(key=='Q'))  ships.get(0).turnTurretLeft = true;
    if ((key == 'e')||(key=='E'))  ships.get(0).turnTurretRight = true;
    if (key == ' ')  ships.get(0).fire = true;

    if ((keyCode==UP)||(key==56))  ships.get(1).speedUp = true;
    if ((keyCode==DOWN)||(key==50))  ships.get(1).slowDown = true;
    if ((keyCode==LEFT)||(key==52))  ships.get(1).turnLeft = true;
    if ((keyCode==RIGHT)||(key==54)) ships.get(1).turnRight = true;
    if (key == 55)  ships.get(1).turnTurretLeft = true;
    if (key == 57)  ships.get(1).turnTurretRight = true;
    if (key == 48)  ships.get(1).fire = true;
  }
}

void keyReleased() {
  if (!mapScreen) {
    if ((key == 'w')||(key=='W'))  ships.get(0).speedUp = false;
    if ((key == 's')||(key=='S'))  ships.get(0).slowDown = false;
    if ((key == 'a')||(key=='A'))  ships.get(0).turnLeft = false;
    if ((key == 'd')||(key=='D'))  ships.get(0).turnRight = false;
    if ((key == 'q')||(key=='Q'))  ships.get(0).turnTurretLeft = false;
    if ((key == 'e')||(key=='E'))  ships.get(0).turnTurretRight = false;
    if (key == ' ')  ships.get(0).fire = false;
    if ((key == 'x')||(key=='X'))  ships.get(0).warp = !ships.get(0).warp;

    if ((keyCode==UP)||(key==56))  ships.get(1).speedUp = false;
    if ((keyCode==DOWN)||(key==50))  ships.get(1).slowDown = false;
    if ((keyCode==LEFT)||(key==52))  ships.get(1).turnLeft = false;
    if ((keyCode==RIGHT)||(key==54)) ships.get(1).turnRight = false;
    if (key == 55)  ships.get(1).turnTurretLeft = false;
    if (key == 57)  ships.get(1).turnTurretRight = false;
    if (key == 48)  ships.get(1).fire = false;
    if (key == 46)  ships.get(1).warp = !ships.get(1).warp;
  }
}