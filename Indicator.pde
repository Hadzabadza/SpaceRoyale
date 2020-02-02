class Indicator{
  Object parent;
  PVector screenPos;
  PVector size;
  
  Indicator(float x, float y, float sX, float sY, Object _parent){
  	screenPos = new PVector(x,y);
  	size = new PVector(sX,sY);
  	parent=_parent;
  }

  void draw(PGraphics rr){
  	noFill();
  	stroke(120+120*sin((float)frameCount/3),80+80*sin((float)frameCount/3),0);
  	rect(screenPos.x, screenPos.y, size.x, size.y);
  }
}


class VelocityIndicator extends Indicator{
  VelocityIndicator(float x, float y, float sX, float sY, Object _parent){
	super(x,y,sX,sY,_parent);
  }
}

class HeatIndicator extends Indicator{
	HeatIndicator(float x, float y, float sX, float sY, Object _parent){
		super(x,y,sX,sY,_parent);
	}
}
