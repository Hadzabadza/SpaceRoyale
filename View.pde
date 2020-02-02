class View {
  PVector dimension;
  PVector pos;
  PGraphics screen;
  String viewName;
  int id;
  Object follow;
  boolean active;

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Init functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    General functions                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  View(PVector _dimension, PVector _pos, String _viewName, int _id, Object _follow) {
    dimension=new PVector(_dimension.x, _dimension.y);
    pos=new PVector(_pos.x, _pos.y);
    viewName=_viewName;
    id=_id;
    screen=createGraphics(floor(dimension.x), floor(dimension.y), P3D);
    active=true;
    view.add(this);
    follow=_follow;
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Update functions                                  //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                     Draw functions                                   //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

  void draw(PGraphics rr) {    
    if (active) {
      screen.beginDraw();
      screen.background(30+15*cos(radians(frameCount*2)), 45+23*cos(radians(frameCount*2)), 65+33*cos(radians(frameCount*2)));
      if (follow!=null) screen.camera(follow.pos.x, follow.pos.y, 100, follow.pos.x, follow.pos.y, 0.0, 0.0, 1.0, 0.0);
      for (Object o : objects) o.draw(screen);
      screen.endDraw();
      rr.strokeWeight(1);
      rr.stroke(255);
      rr.noFill();
      rr.image(screen, pos.x, pos.y);
      rr.rect(pos.x-1, pos.y-15, screen.width, screen.height+15);
      rr.fill(66,100,180);
      rr.rect(pos.x, pos.y-14, screen.width, 15);
      rr.textAlign(LEFT);
      rr.fill(255);
      rr.text(viewName, pos.x+3, pos.y+6);
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                    Object management                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------

}