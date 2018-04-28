class Terrain {
  int x, y;
  float elevation;
  color fill;
  float depth;
  boolean water;
  float lava;
  boolean volcano;
  int volcanoTime;
  int index;

  Planet p;

  Terrain(int _x, int _y, float elev, Planet _p, int index) {
    x=_x;
    y=_y;
    p=_p;
    fill=0;
    elevation=elev;
    this.index=index;
  }
  /*
  boolean checkHover() {
    int leftBorder=(width-p.map.width)/2;
    if ((((cursor.x>=x*p.mapRes-p.mapRes/2+leftBorder)&&(cursor.x<x*p.mapRes+p.mapRes/2+(width-p.map.width)/2))&&((cursor.y>=y*p.mapRes-p.mapRes/2+(height-p.map.height)/2)&&(cursor.y<y*p.mapRes+p.mapRes/2+(height-p.map.height)/2)))||((cursor.x==x*p.mapRes+(width-p.map.width)/2)&&(cursor.y==y*p.mapRes+(height-p.map.height)/2))) {        
      hovered=true;
      return true;
    } else
    {
      hovered=false;
      return false;
    }
  }
  */
  void draw() {
    if (heightColour)
    {
      if (water)
      {
        if (1-abs(cos(radians(frameCount)))<depth||depth>0.6)
        {
          fill(fill);
        } else
        {
          fill(color(map(elevation, p.minHeight, p.maxHeight, 255, 0), map(elevation, p.minHeight, p.maxHeight, 0, 255), 0));
        }
      } else
      {
        fill(fill);
      }
    } else
    {
      if (water)
      {
        if (1-abs(cos(radians(frameCount)))<depth||depth>0.7)
        {
          fill(fill);
        } else
        {
          fill(elevation);
        }
      } else
      {
        fill(elevation);
      }
      if (lava!=0)
      {
        fill(50+lava*3, lava, 0);
      }
    }


    if (frameCount%5==0)
    {
      if (!water)
      {
        fill=color(map(elevation, p.minHeight, p.maxHeight, 255, 0), map(elevation, p.minHeight, p.maxHeight, 0, 255), 0);
      } else
      {
        //fill=color(0, 0, map(elevation, p.minHeight*0.5, (p.minHeight+(p.avgHeight-p.minHeight)*0.4)*1.3+50, 0, 255));
        fill=color(0, 0, round(250-200*depth));
      }
      propagateLava();
      depth=map(elevation, p.minHeight, (p.minHeight+(p.avgHeight-p.minHeight)*0.4), 1, 0);
      if (depth>0)
      {
        water=true;
      } else
      {
        water=false;
        depth=0;
      }
    }

    noStroke();
    rect(x*p.mapRes-mapScreenShift.x+(width-p.map.width)/2, y*p.mapRes-mapScreenShift.y+(height-p.map.height)/2, p.mapRes, p.mapRes);
    /*
    point(x*p.mapRes-mapScreenShift.x+(width-p.map.width)/2, y*p.mapRes-mapScreenShift.y+(height-p.map.height)/2);
     */
     if (p.selected==this)
     {
       drawSelection();
     }
  };
  void build() {
  }
  void drawSelection(){
      strokeWeight(1);
      //pushMatrix();
      //translate(0, 0, 1);
      stroke(130,150,0);
      line(-width,y*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2,width,y*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2);
      line(x*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2,-height,x*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2,height);
      stroke(100+50*cos(frameCount/2), 0, 0);
      strokeWeight(ship.land.mapRes);
      point((x-1)*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2, y*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2);
      point((x+1)*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2, y*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2);
      point(x*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2, (y-1)*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2);
      point(x*ship.land.mapRes-mapScreenShift.x+(width-p.map.width)/2, (y+1)*ship.land.mapRes-mapScreenShift.y+(height-p.map.height)/2);
      //popMatrix();
  }
  void volcanize() {
    volcanoTime=300;
  }

  void propagateLava() {
    if (volcanoTime>0)
    {
      float lavaIncrement=300-lava;
      for (Terrain t : p.terrain)
      {
        t.elevation-=lavaIncrement/p.terrain.length;
      }
      lava+=lavaIncrement;
      volcanoTime--;
    }
    if (lava!=0)
    {

      if (lava-lava*0.1>=1)
      {
        int propagated=0;
        Terrain[] propagation=new Terrain[4];
        float avgHeight=elevation;
        float avgLava=lava;

        if (index!=0)
        if (index-p.surface.height>=0)
          if (p.terrain[index-p.surface.height].elevation+p.terrain[index-p.surface.height].lava<elevation+lava)
          {
            propagated++;
            propagation[propagated-1]=p.terrain[index-p.surface.height];
          }
        if (index+p.surface.height<p.terrain.length)
          if (p.terrain[index+p.surface.height].elevation+p.terrain[index+p.surface.height].lava<elevation+lava)
          {
            propagated++;
            propagation[propagated-1]=p.terrain[index+p.surface.height];
          }
          if (p.terrain[index-1].elevation+p.terrain[index-1].lava<elevation+lava)
          {
            propagated++;
            propagation[propagated-1]=p.terrain[index-1];
          }
        if (index!=p.terrain.length-1)
          if (p.terrain[index+1].elevation+p.terrain[index+1].lava<elevation+lava)
          {
            propagated++;
            propagation[propagated-1]=p.terrain[index+1];
          }
        for (int i=0; i<propagated; i++)
        {
          avgHeight+=propagation[i].elevation;
          avgLava+=propagation[i].lava;
        }
        avgHeight/=propagated+1;
        avgLava/=propagated+1;
        for (int i=0; i<propagated; i++)
        {
          propagation[i].lava=avgHeight+avgLava-propagation[i].elevation;
        }
        lava=avgHeight+avgLava-elevation;
        elevation+=1+lava*0.1;
        lava-=1+lava*0.1;
      } else
      {
        elevation+=lava;
        lava=0;
      }
    }
  }
}