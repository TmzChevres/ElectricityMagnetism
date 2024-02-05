class Visualizer extends LoopThread {
  PImage image;
  PGraphics buffer;
  boolean updated = false;

  int filterType;
  float quality;

  Visualizer() {
    super(frameRate);
    startLoop();
    image = createImage(0, 0, ARGB);//prevent nullpointerexception
  }

  void execute() {
    filterType = menu.getMenuObject("filter/type").getValue();
    int tempQ = filterType = menu.getMenuObject("filter/definition").getValue();
    if (tempQ==0) quality = -1;
    else if (tempQ==1) quality = pow(10, maxVisibleMagnitude().x-1);
    else if (tempQ==2) quality = 0;//maximum

    //can not draw directly, use buffer image to get grabbed by main
    buffer = createGraphics(width, height);
    buffer.beginDraw();

    drawFilter();

    buffer.endDraw();

    image = buffer.copy();
  }

  public PImage getVis() {
    return image.copy();
  }
  public PImage getBuffer(){
    return buffer;
  }
  
  
  public color getFilterColor(PVector pos){
    color c = 0x00000000;
    colorMode(HSB,TWO_PI,100,100);
    switch(filterType){
      case 0:
        PVector field = sim.getElectricField(pos);
        c = color(field.heading()+PI, 100, (log10(field.mag())+10)*40);
        break;
    }
    colorMode(RGB, 255, 255, 255);
    return c;
  }


  //since the viewport may be moving, scx and scy can not be used
  //return center.x+(vpX - width/2)/scale.x;
  //return center.y-(vpY - height/2)/scale.y;
  
  public void drawFilter() {
    PVector lockCenter = center.copy();
    PVector lockScale = scale.copy();
    PVector lockSize = new PVector(width,height);
    if (sim.objects.size()>0) {
      buffer.fill(0);
      PVector pos = new PVector();
      for (int x=0; x<width; x++) {
        for (int y=0; y<height; y++) {
          pos.x=lockCenter.x+(x - lockSize.x/2)/lockScale.x;
          pos.y=lockCenter.y-(y - lockSize.y/2)/lockScale.y;
          buffer.stroke(getFilterColor(pos));
          buffer.point(x, y);
        }
      }
    }
  }
  //public void drawFilter(float delta) {
  //  drawFilter(delta, delta);
  //}
  //public void drawFilter(float dX, float dY) {
  //}

  /*
public void drawElectricField() {
   if (objects.size()>0) {
   fill(0);
   colorMode(HSB, TWO_PI, 100, 100);
   PVector pos = new PVector();
   for (int x=0; x<width; x++) {
   for (int y=0; y<height; y++) {
   pos.x=scX(x);
   pos.y=scY(y);
   PVector field = sim.getElectricField(pos);
   stroke(field.heading()+PI, 100,(log10(field.mag())+10)*40);
   point(x, y);
   }
   }
   colorMode(RGB, 255, 255, 255);
   }
   }
   public void drawElectricField(float delta){drawElectricField(delta,delta);}
   public void drawElectricField(float dX,float dY) {
   if(dX<1/scale.x && dY<1/scale.y){
   drawElectricField();
   }else{
   if(dX<1/scale.x) dX=1/scale.x;
   if(dY<1/scale.y) dY=1/scale.y;
   if (objects.size()>0) {
   noStroke();
   colorMode(HSB, TWO_PI, 100, 100);
   int saveRectMode = getGraphics().rectMode;
   rectMode(CENTER);
   for (float x=dX*(Math.round((scX(0)/dX)/dX))-dX/2; x<scX(width)+dX; x+=dX) {
   for (float y=dY*(Math.round((scY(height)/dY)/dY))-dY/2; y<scY(0)+dX; y+=dY) {
   PVector field = sim.getElectricField(new PVector(x,y));
   fill(field.heading()+PI, 100, (log10(field.mag())+10)*40,192);
   stroke(0,0);
   rect(vpX(x), vpY(y),dX*scale.x,dY*scale.y);
   }
   }
   colorMode(RGB, 255, 255, 255);
   rectMode(saveRectMode);
   }
   }*/
}
