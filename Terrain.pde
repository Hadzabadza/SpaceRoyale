class Terrain {
  int x, y;
  int index;
  Planet p;

  float[] resources=new float[resourceNames.length*3];  //Resources and their states of matter. 0 - solid, 1 - liquid - 2 - gas.
  float totalOre;
  float totalLiquid;
  float totalGas;
  
  float lava;
  float liquidPressure;                                 //Used to simulate liquids being pushed out of the explosion epicentre
  float temperature;
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
    temperature=p.ambientTemp;
    float[] resourceShare=new float[resourceNames.length];
    float totalresourceShares=0;
    float noiseOffset=-p.orbitNumber*9321;
    for (int i=0; i<resourceNames.length; i++) {
      resourceShare[i]=noise(float(x)/100+noiseOffset+i*1000,float(y)/100+noiseOffset+i*1000);//random(0,1);
      totalresourceShares+=resourceShare[i];
    }
    for (int i=0; i<resourceNames.length; i++) resources[i*3]=elev*resourceShare[i]/totalresourceShares;
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
  
  color colouriseByResource(int resNumber){
    float divider=(p.maxRes[resNumber*3]+p.maxRes[resNumber*3+1]+p.maxRes[resNumber*3+2]);
    float brightness;
    if (divider==0) return color(totalOre); 
    else brightness=(resources[resNumber*3]+resources[resNumber*3+1]+resources[resNumber*3+2])/divider;
    if (p.selected==this) println(brightness);
    switch (resNumber){
      case 0:{
        return color(80*brightness);
      }
      case 1:{
        return color(200*brightness,40*brightness,255*brightness);
      }
      case 2:{
        return color(80*brightness,255*brightness,80*brightness);
      }
      case 3:{
        return color(120*brightness);
      }
      case 4:{
        return color(255*brightness,160*brightness,30*brightness);
      }
      case 5:{
        return color(255*brightness,255*brightness,40*brightness);
      }
      case 6:{
        return color(240*brightness,80*brightness,0);
      }
      case 7:{
        return color(60*brightness,255*brightness,255*brightness);
      }
      default:{
        return color(random(255));
      }
    }
  }


  void propagateLava() {  
    if (volcanoTime>0)
    {
      createLava();
      volcanoTime--;
    }
    if (lava>0)
    {
      if (lava>=0.08) moveLava();
      else removeLavaRemnants();
    }
  }

  void createLava() {

    float lavaIncrement=100-lava;
    for (Terrain t : p.terrain)
    {
      t.totalOre-=lavaIncrement/p.terrain.length;
    }
    lava+=lavaIncrement;
    lava+=totalOre*0.01;
    totalOre*=0.99;
    liquidPressure+=lavaIncrement;
  }

  void blopLava() {
    Terrain t;
    volcanoTime=0;
    int rad=30;
    float boom;
    float neighDist;
    for (int i=-rad; i<rad; i++)
      for (int j=-rad; j<rad; j++) {
        neighDist=dist(0, 0, i, j)-random(float(rad)*0.1);
        if (neighDist<=rad) {
          t=getNeighbour(i, j);
          boom=0.3*cos(neighDist/rad*HALF_PI);
          // println(neighDist/rad*PI+" "+neighDist+" "+boom);
          t.lava+=t.totalOre*boom;
          t.liquidPressure+=1000*boom;
          t.totalOre*=1-boom;
        }
      }
  }

  void plopLava() {
    Terrain t;
    volcanoTime=0;
    float rad=30;
    for (int i=-30; i<rad; i++) {
      for (int j=-30; j<rad; j++) {
        if (dist(0, 0, i, j)<rad) {
          t=getNeighbour(i, j);
          t.lava+=t.totalOre*0.5;
          t.totalOre*=0.5;
        }
      }
    }
  }
  
  void moveLava() {
    cooldownLava();
    int propagations=0;
    float lowestFall=0;
    float avgPressure=liquidPressure;
    float totalFall=0;
    float currProp=0;
    Terrain t;
    int degStart=round(random(8));
    for (int deg=0+45*degStart; deg<360+45*degStart; deg+=45) {
      t=getNeighbour(round(cos(radians(deg))), round(sin(radians(deg))));
      if (t.totalOre+t.lava+t.liquidPressure<totalOre+lava+liquidPressure)//&&(lava>0))
      {
        propMatrix[propagations]=t;
        PROPortions[propagations]=(t.totalOre+t.lava+t.liquidPressure)/(totalOre+lava+liquidPressure);
        if (lowestFall<(-t.totalOre-t.lava-t.liquidPressure+totalOre+lava+liquidPressure)) lowestFall=-t.totalOre-t.lava-t.liquidPressure+totalOre+lava+liquidPressure;
        totalFall+=PROPortions[propagations];
        propagations++;
        avgPressure+=t.liquidPressure;
      }
    }
    if (lowestFall>lava) lowestFall=lava;
    for (int i=0; i<propagations; i++) {
      if (totalFall!=0){
        currProp=PROPortions[i]/totalFall;
        propMatrix[i].lava+=lowestFall*currProp;
        propMatrix[i].liquidPressure+=liquidPressure*currProp;
      }
      propMatrix[i].liquidPressure=avgPressure/(propagations+1);
    }
    lava-=lowestFall;
    liquidPressure=avgPressure/(propagations+1);
    //liquidPressure-=totalFall;
  }

  void cooldownLava() {
    totalOre+=lava*0.02;
    lava*=0.98;
    if (lava<=0.08) {
      removeLavaRemnants();
    }
  }

  void removeLavaRemnants() {
    totalOre+=lava;
    lava=0;
    liquidPressure=0;
  }
  
  void moveLiquids(){
    int propagations=0;
    float lowestFall;
    float avgHeight=totalOre;
    float avgPressure=liquidPressure;
    float avgLava=lava;
    Terrain t;
    int degStart=round(random(8));
    for (int deg=0+45*degStart; deg<360+45*degStart; deg+=45) {
      t=getNeighbour(round(cos(radians(deg))), round(sin(radians(deg))));
      if (t.totalOre+t.lava+t.liquidPressure<totalOre+lava+liquidPressure)
      {
        propagations++;
        propMatrix[propagations-1]=t;
      }
    }
  }
  
  void moveGas(){
  }
  
  void melt(int resourceNumber){
    resources[resourceNumber*3+1]+=resources[resourceNumber*3];
    totalOre-=resources[resourceNumber*3];
    totalLiquid+=resources[resourceNumber*3];
    resources[resourceNumber*3]=0;
  }
  
  void vaporise(int resourceNumber){
    resources[resourceNumber*3+2]+=resources[resourceNumber*3+1];
    totalLiquid-=resources[resourceNumber*3+1];
    totalGas+=resources[resourceNumber*3+1];
    resources[resourceNumber*3+1]=0;
  }
  
  void solidify(int resourceNumber){
    resources[resourceNumber*3]+=resources[resourceNumber*3+1];
    totalOre+=resources[resourceNumber*3+1];
    totalLiquid-=resources[resourceNumber*3+1];
    resources[resourceNumber*3+1]=0;
  }

  void condense(int resourceNumber){
    resources[resourceNumber*3+1]+=resources[resourceNumber*3+2];
    totalLiquid+=resources[resourceNumber*3+2];
    totalGas-=resources[resourceNumber*3+2];
    resources[resourceNumber*3+2]=0;
  }
  
  Terrain getNeighbour(int _x, int _y) {
    int neighX=x+_x;
    int neighY=y+_y;
    if (neighY<0) {
      neighY=abs(neighY);
      neighX+=p.terrainSize/2;
    }
    if (neighY>=p.terrainSize) {
      neighY=p.terrainSize*2-neighY-1;
      neighX+=p.terrainSize/2;
    }
    if (neighX>=0) {
      if (neighX>=p.terrainSize) neighX=neighX-p.terrainSize;
    } else neighX=p.terrainSize+neighX;
    return(p.terrain[neighX+neighY*p.terrainSize]);
  }

  void update() {
    //liquidPressure*=0.98;
    if (!water)
    {
      fill=color(map(totalOre, p.minHeight, p.maxHeight, 255, 0), map(totalOre, p.minHeight, p.maxHeight, 0, 255), 0);
    } else
    {
      //fill=color(0, 0, map(totalOre, p.minHeight*0.5, (p.minHeight+(p.avgHeight-p.minHeight)*0.4)*1.3+50, 0, 255));
      fill=color(0, 0, round(250-200*depth));
    }
    //propagateLava();
    depth=depthCalculation();
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
    for (int i=0; i<resourceNames.length; i++){
      if (temperature>resourceTemperatureThresholds[i*2+1]){
        vaporise(i);
        melt(i);        
      }
      else if (temperature<resourceTemperatureThresholds[i*2]){
        solidify(i);
        condense(i);
      }
      else {
        melt(i);
        condense(i);
      }
    }
  }

  float depthCalculation() {
    return map(totalOre, p.minHeight, (p.minHeight+(p.avgHeight-p.minHeight)*p.waterLevel), 1, 0);
  }

  void drawSelection(PGraphics rr, Ship ship) {
    rr.strokeWeight(1);
    rr.stroke(ship.c);
    rr.noFill();
    rr.line(-width, (y+0.5)*p.mapRes, (x)*p.mapRes, (y+0.5)*p.mapRes);
    rr.line((x+1)*p.mapRes, (y+0.5)*p.mapRes, width, (y+0.5)*p.mapRes);
    rr.line(x*p.mapRes, -height, (x+0.5)*p.mapRes, y*p.mapRes);
    rr.line((x+0.5)*p.mapRes, (y+1)*p.mapRes, (x+0.5)*p.mapRes, height);
    rr.rect((x+0.5)*p.mapRes, (y+0.5)*p.mapRes, p.mapRes, p.mapRes);
    //rr.stroke(100+50*cos(gameTime), 0, 0);
    //rr.strokeWeight(ship.land.mapRes);
    /*rr.point((x-1)*p.mapRes, y*p.mapRes);
     rr.point((x+1)*p.mapRes, y*p.mapRes);
     rr.point(x*p.mapRes, (y-1)*p.mapRes);
     rr.point(x*p.mapRes, (y+1)*p.mapRes);
     */
  }
 
  void draw(Map m) {
    //totalOre=stone+solane+perditium+etramite+omnitium;
    if (m.heightMap)
    {
      /*
      if (water) rr.fill(color(map(totalOre, p.minHeight, p.maxHeight, 255, 0), map(totalOre, p.minHeight, p.maxHeight, 0, 255), 0));
       else rr.fill(fill);*/
      m.screen.fill(colouriseByHeight(totalOre, p.minHeight, p.maxHeight, p.waterLevel));
    } else if (m.pressureMap) {
      if (liquidPressure>0) m.screen.fill(liquidPressure, 0, 0);      
      else m.screen.fill(totalOre);
    } else if (m.resourceMap){
      //if (resources[m.shownResource*3]>Settings.resDisplayThreshold) 
      m.screen.fill(colouriseByResource(m.shownResource));
      //else m.screen.fill(totalOre);
    } else
    {
      if (water) m.screen.fill(0, 0, waterColour/2+waterColour/3+waterColour/3*(cos(gameTime)));
      else m.screen.fill(totalOre);
      if (lava!=0) 
        if (lava>2) m.screen.fill(50+lava*3, lava, 0);
        else if (depth<=0) m.screen.fill(25*lava+(1-lava/2)*totalOre/2, totalOre/(lava+2), totalOre/(lava+2));
        else m.screen.fill(32.6*lava, 20.6*lava, 220*(1-depth));
    }

    m.screen.noStroke();
    m.screen.rect((x+0.5)*p.mapRes, (y+0.5)*p.mapRes, p.mapRes, p.mapRes);
    if (p.selected==this) drawSelection(m.screen, ships[0]); //TODO: Multiple ships
    if (frameCount%5==0) update();
  };
}
