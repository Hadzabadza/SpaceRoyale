class Terrain {
  int x, y;
  int index;
  Planet p;

  float forazol;
  float totalOre;
  float stone;
  float solane;
  float perditium;
  float etramite;
  float omnitium;
  float bedrock;

  float lava;
  float pressure;
  float temperature;
  boolean volcano;
  int volcanoTime;

  float waterColour;
  color fill;
  float depth;
  boolean water;

  Terrain(int _x, int _y, float elev, Planet _p, int index) {
    x=_x;
    y=_y;
    p=_p;
    fill=0;
    totalOre=elev;
    this.index=index;
  }

  void build() {
  }

  void volcanize() {
    volcanoTime=100;
  }

  color colouriseByHeight(float hgt, float min, float max, float seaLevel) {
    float bottom=min;
    float top=(min+(p.avgHeight-min)*seaLevel);
    if (hgt<top) {
      return color(map(hgt, bottom, top, 0, 100), map(hgt, bottom, top, 0, 100), map(hgt, bottom, top, 0, 220));
    }
    bottom=top;
    top=top+(max-top)*0.5;
    if (hgt<top) {
      return color(map(hgt, bottom, top, 50, 220), map(hgt, bottom, top, 150, 255), 0);
    }
    bottom=top;
    top=top+(max-top)*0.5;
    if (hgt<top) {
      return color(round(map(hgt, bottom, top, 220, 100)), round(map(hgt, bottom, top, 255, 50)), 0);
    }
    bottom=top;
    top=top+(max-top)*0.3;
    if (hgt<top) {
      return color(round(map(hgt, bottom, top, 100, 220)), round(map(hgt, bottom, top, 50, 100)), round(map(hgt, bottom, max, 0, 100)));
    }
    bottom=top;
    return color(round(map(hgt, bottom, max, 220, 255)), round(map(hgt, bottom, max, 100, 255)), round(map(hgt, bottom, max, 0, 255)));
  }

  void propagateLava() {  
    if (volcanoTime>0)
    {
      createLava();
      volcanoTime--;
    }
    if (lava!=0)
    {
      //if (lava-lava*0.1>=1)
      if (lava>=0.08)
        moveLava();
      else removeLavaRemnants();
    }
  }

  void createLava() {

    float lavaIncrement=300-lava;
    for (Terrain t : p.terrain)
    {
      t.totalOre-=lavaIncrement/p.terrain.length;
    }
    lava+=lavaIncrement;
  }

  void plopLava() {
    volcanoTime=0;
    float rad=30;
    for (int i=-30; i<rad; i++)
      for (int j=-30; j<rad; j++) {
        if (dist(0, 0, i, j)<rad) {
          getNeighbour(i, j).lava+=getNeighbour(i, j).totalOre*0.5;
          getNeighbour(i, j).totalOre*=0.5;//getNeighbour(i, j).totalOre*0.1;
          //getNeighbour(i, j).totalOre*=0.9;
        }
      }
  }

  void moveLava() {
    int propagated=0;
    Terrain[] propagation=new Terrain[8];
    float avgHeight=totalOre;
    float avgLava=lava;
    Terrain t;
    for (int deg=0; deg<360; deg+=45) {
      t=getNeighbour(round(cos(radians(deg))), round(sin(radians(deg))));
      if (t.totalOre+t.lava<totalOre+lava)
      {
        propagated++;
        propagation[propagated-1]=t;
      }
    }
    for (int i=0; i<propagated; i++)
    {
      avgHeight+=propagation[i].totalOre;
      avgLava+=propagation[i].lava;
    }
    avgHeight/=propagated+1;
    avgLava/=propagated+1;
    for (int i=0; i<propagated; i++)
    {
      propagation[i].lava=avgHeight+avgLava-propagation[i].totalOre;
    }
    lava=avgHeight+avgLava-totalOre;
    totalOre+=lava*0.05;
    lava-=lava*0.05;
  }

  void removeLavaRemnants() {
    totalOre+=lava;
    lava=0;
  }

  Terrain getNeighbour(int _x, int _y) {
    int neighX=x+_x;
    int neighY=y+_y;
    if (neighY<0) {
      neighY=abs(neighY);
      neighX+=p.surface.width/2;
    }
    if (neighY>=p.surface.height) {
      neighY=p.surface.height*2-neighY-1;
      neighX+=p.surface.width/2;
    }
    if (neighX>=0) {
      if (neighX>=p.surface.width) neighX=neighX-p.surface.width;
    } else neighX=p.surface.width+neighX;
    return(p.terrain[neighX+neighY*p.surface.width]);
  }
  
  void update() {
    if (!water)
    {
      fill=color(map(totalOre, p.minHeight, p.maxHeight, 255, 0), map(totalOre, p.minHeight, p.maxHeight, 0, 255), 0);
    } else
    {
      //fill=color(0, 0, map(totalOre, p.minHeight*0.5, (p.minHeight+(p.avgHeight-p.minHeight)*0.4)*1.3+50, 0, 255));
      fill=color(0, 0, round(250-200*depth));
    }
    //propagateLava();
    //depth=map(totalOre, p.minHeight, p.minHeight+(p.maxHeight-p.avgHeight)*p.waterLevel, 1, 0);
    depth=map(totalOre, p.minHeight, (p.minHeight+(p.avgHeight-p.minHeight)*p.waterLevel), 1, 0);
    if (depth>0)
    {
      water=true;
      waterColour=255*(1-depth);
      fill=color(0, 0, waterColour);
    } else
    {
      water=false;
      depth=0;
    }
  }

  void drawSelection(PGraphics rr, Ship ship) {
    rr.strokeWeight(1);
    rr.stroke(ship.c);
    rr.line(-width, y*p.mapRes, width, y*p.mapRes);
    rr.line(x*p.mapRes, -height, x*p.mapRes, height);
    rr.stroke(100+50*cos(gameTime), 0, 0);
    rr.strokeWeight(ship.land.mapRes);
    rr.point((x-1)*p.mapRes, y*p.mapRes);
    rr.point((x+1)*p.mapRes, y*p.mapRes);
    rr.point(x*p.mapRes, (y-1)*p.mapRes);
    rr.point(x*p.mapRes, (y+1)*p.mapRes);
  }

  void draw(PGraphics rr) {
    //totalOre=stone+solane+perditium+etramite+omnitium;
    if (heightColour)
    {
      /*
      if (water) rr.fill(color(map(totalOre, p.minHeight, p.maxHeight, 255, 0), map(totalOre, p.minHeight, p.maxHeight, 0, 255), 0));
       else rr.fill(fill);*/
      rr.fill(colouriseByHeight(totalOre, p.minHeight, p.maxHeight, p.waterLevel));
    } else
    {
      if (water) rr.fill(0, 0, waterColour/2+waterColour/3+waterColour/3*(cos(gameTime)));
      else rr.fill(totalOre);
      if (lava!=0) 
        if (lava>2) rr.fill(50+lava*3, lava, 0);
        else if (depth<=0) rr.fill(25*lava+(1-lava/2)*totalOre, 0, 0);
        else rr.fill(32.6*lava, 20.6*lava, 220*(1-depth));
    }

    rr.noStroke();
    rr.rect(x*p.mapRes, y*p.mapRes, p.mapRes, p.mapRes);
    if (p.selected==this) drawSelection(rr, ships[0]); //TODO: Multiple ships
    if (frameCount%5==0) update();
  };
}
