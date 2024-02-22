class Visualizer extends LoopThread {
  PImage image;
  PGraphics buffer;
  boolean updated = false, active = false;

  int filterType;
  float quality;

  Visualizer() {
    super(frameRate);
    startLoop();
    image = createImage(0, 0, ARGB);//prevent nullpointerexception
  }

  //CALLED MANUALLY IN MAIN
  void draw() {
    drawFieldLine(mousePos, 256, 0);
    drawEquipotentialLine(mousePos, 256, 0);
  }

  //IS CALLED AUTOMATICALLY BY LoopThread - DO NOT DRAW TO SCREEN
  void execute() {
    if (!updated) {
      active = true;
      filterType = (menu!=null && menu.getMenuObject("filter/type")!=null ? menu.getMenuObject("filter/type").getValue():0);
      int tempQ  = (menu!=null && menu.getMenuObject("filter/definition")!=null ? menu.getMenuObject("filter/definition").getValue():0);
      if (tempQ==0) quality = -1; //OFF
      else if (tempQ==1) quality = pow(10, maxVisibleMagnitude().x-1); //defined def
      else if (tempQ==2) quality = 0;//maximum
      //can not draw directly, use buffer image to get grabbed by main
      buffer = createGraphics(width, height);
      buffer.beginDraw();

      drawFilter(quality);

      buffer.endDraw();
      image = buffer.copy();
      if (active) {
        updated = true;
        active = false;
      }
    }
  }

  public PImage getVis() {
    return image.copy();
  }
  public PImage getBuffer() {
    return buffer;
  }

  public void updateVisualizer() {
    active = false;
    updated = false;
  }


  public color getFilterColor(PVector pos) {
    color c = 0x00000000;
    switch(filterType) {
      case 0:
        colorMode(HSB, TWO_PI, 100, 100);
        PVector field = sim.getElectricField(pos);
        c = color(field.heading()+PI, 100, (log10(field.mag())+10)*40);
        break;
      case 1:
      //  colorMode(RGB, 255, 255, 255, 1.0);
        float potential = sim.getElectricPotential(pos);
        float lerp = ((-log10(abs(potential)))-8)/(10-8); //e-8 -> full color, e-10 -> black
        c = lerpColor((potential>0?Color.POTENTIAL_POS:Color.POTENTIAL_NEG),color(0),lerp);
        break;
    }
    colorMode(RGB, 255, 255, 255,255);
    return c;
  }


  //since the viewport may be moving, scx and scy can not be used
  //return center.x+(vpX - width/2)/scale.x;
  //return center.y-(vpY - height/2)/scale.y;

  public void drawFilter() {
    if (sim.objects.size()>0) {
      PVector lockCenter = center.copy();
      PVector lockScale = scale.copy();
      PVector lockSize = new PVector(width, height);
      PVector pos = new PVector();
      buffer.fill(0);
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
  public void drawFilter(float delta) {
    if (delta==0) drawFilter();
    else if (delta>0) drawFilter(delta, delta);
  }
  public void drawFilter(float dX, float dY) {
    //println("drawFilter("+dX+","+dY+")");
    if (sim.objects.size()>0) {
      PVector lockCenter = center.copy();
      PVector lockScale = scale.copy();
      PVector lockSize = new PVector(width, height);
      PVector init = new PVector(roundMultiple(scX(0), dX)-dX, roundMultiple(scY(0), dY)+dY);
      PVector pos = init.copy();
      PVector max = new PVector(roundMultiple(scX(width), dX)+dX, roundMultiple(scY(height), dY)-dY);

      //println(scX(0),scY(0),'\t',roundMultiple(scX(0),dX),roundMultiple(scY(0),dY));
      buffer.fill(0);
      //println(pos.x, pos.y, max.x, max.y);
      rectMode(CENTER);
      noStroke();
      while (pos.x<max.x) {
        while (pos.y>max.y) {
          buffer.fill(0x20000000 ^ getFilterColor(pos));
          //buffer.fill(0x66FF00FF);
          buffer.rect(lockScale.x*(pos.x-lockCenter.x)+lockSize.x/2, lockScale.y*(lockCenter.y-pos.y)+lockSize.y/2, dX*lockScale.x, dY*lockScale.y);
          //buffer.point(lockScale.x*(pos.x-lockCenter.x)+lockSize.x/2,lockScale.y*(lockCenter.y-pos.y)+lockSize.y/2); 
          //(lockScale.x*(pos.x-lockCenter.x)+lockSize.x/2,lockScale.y*(lockCenter.y-pos.y)+lockSize.y/2);
          pos.y-=dY;
        }
        pos.x+=dX;
        pos.y=init.y;
      }
      //for (int x=0; x<width; x++) {
      //  for (int y=0; y<height; y++) {
      //    pos.x=lockCenter.x+(x - lockSize.x/2)/lockScale.x;
      //    pos.y=lockCenter.y-(y - lockSize.y/2)/lockScale.y;
      //    buffer.stroke(getFilterColor(pos));
      //    buffer.point(x, y);
      //  }
      //}
    }
  }


  //CALL IN MAIN THREAD
  public void drawFieldLine(PVector start, int steps, float delta) {
    if (sim.objects.size()>0) {
      if (delta<1/scale.x) delta = 1/scale.x;
      stroke(Color.FIELD_LINE);
      PVector loc1 = start.copy();
      PVector loc2 = start.copy();
      PVector prev1 = loc1.copy();
      PVector prev2 = loc2.copy();
      for (int i=0; i<steps; i++) {
        //stroke(int(255.0*i/steps)<<24 ^ Color.FIELD_LINE);
        prev1.set(loc1);
        loc1.add(sim.getElectricField(loc1).normalize().mult(delta));
        line(vpX(prev1.x), vpY(prev1.y), vpX(loc1.x), vpY(loc1.y));

        prev2.set(loc2);
        loc2.sub(sim.getElectricField(loc2).normalize().mult(delta));
        line(vpX(prev2.x), vpY(prev2.y), vpX(loc2.x), vpY(loc2.y));
      }
    }
  }

  public void drawEquipotentialLine(PVector start, int steps, float delta) {
    if (sim.objects.size()>0) {
      if (delta<1/scale.x) delta = 1/scale.x;
      stroke(Color.EQUIPOTENTIAL_LINE);
      PVector loc1 = start.copy();
      PVector loc2 = start.copy();
      PVector prev1 = loc1.copy();
      PVector prev2 = loc2.copy();
      for (int i=0; i<steps; i++) {
        //stroke(int(255.0*i/steps)<<24 ^ Color.EQUIPOTENTIAL_LINE);
        prev1.set(loc1);
        loc1.add(sim.getElectricField(loc1).normalize().rotate(HALF_PI).mult(delta));
        line(vpX(prev1.x), vpY(prev1.y), vpX(loc1.x), vpY(loc1.y));

        prev2.set(loc2);
        loc2.add(sim.getElectricField(loc2).normalize().rotate(-HALF_PI).mult(delta));
        line(vpX(prev2.x), vpY(prev2.y), vpX(loc2.x), vpY(loc2.y));
      }
    }
  }

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
