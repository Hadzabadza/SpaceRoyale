/*class PWindow extends PApplet {
  int winSize;
  int x, y;
  Ship target;
  PApplet main;
  color back=color(50);

  PWindow(int _winSize, int _x, int _y, Ship sh, PApplet start) {
    super();
    winSize=_winSize;
    x=_x;
    y=_y;
    target=sh;;    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(winSize, winSize, "processing.opengl.PGraphics3D");
  }

  void setup() {
  }

  void draw() {
    background(back);
    camera(target.pos.x, target.pos.y, zoom*600, target.pos.x, target.pos.y, 0.0, 0.0, 1.0, 0.0);
    for (Object o : objects) {
      o.draw(this);
    }
  }
  void keyPressed(){
    main.keyPressed();
  }
  void keyReleased(){
    main.keyReleased();
  }
}*/