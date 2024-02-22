/*
  Tomaz Chevres '24
 AP Physics C - Electricity & Magnetism
 Simulation
 */
PVector scale; //scale of the grid
PVector center;//center of the drawn grid
PVector mousePos;//position of mouse in simulation
PVector pmousePos;

Physics sim;
Visualizer vis;
MenuApplet menu;
void settings() {
  size(600, 400);
}

void setup() {
  surface.setResizable(true);
  surface.setTitle("Viewport");

  scale = new PVector(100, 100);
  center = new PVector(0, 0);
  mousePos = new PVector(0, 0);

  sim = new Physics();
  menu = new MenuApplet();
  menu.setLocation(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame().getX()+width+16,((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame().getY());
  ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).requestFocus();
  vis = new Visualizer();//STARTS VISUALIZER THREAD AUTOMATICALLY
}


void draw() {
  
  //update mousePos
  pmousePos=mousePos.copy();
  mousePos.x = scX(mouseX);
  mousePos.y = scY(mouseY);

  //draw background
  background(Color.BACKGROUND);
  drawGridAxis();
  
  //draw simulation & visualization
  sim.draw();
  image(vis.getVis(), 0, 0);
  vis.draw();
  //println(sim.getElectricPotential(mousePos));
  float potential = sim.getElectricPotential(mousePos);
  float lerp = ((-log10(abs(potential)))-8)/(10-8);
  //println(lerp);
  
  //stroke(0);
  //line(mouseX,mouseY,mouseX+sim.getElectricField(mousePos).normalize().x*20,mouseY-sim.getElectricField(mousePos).normalize().y*20);

  //preview overlays
  float[] data = menu.getData();
  switch(menu.getActionType()) {
    case 0://draw
      switch(menu.getMenuObject("draw/shape").getValue()){
        case 1://charged rod
          if (data[0]==1) {
            stroke(0, 128);
            line(vpX(data[1]), vpY(data[2]), mouseX, mouseY);
          }
          break;
        case 2://infinite rod
          if (data[0]==1) {
            stroke(0, 128);
            if (mousePos.x!=data[1]) {
              line(0, (mouseY-vpY(data[2]))/(mouseX-vpX(data[1]))*(0-vpX(data[1]))+vpY(data[2]), width-1, (mouseY-vpY(data[2]))/(mouseX-vpX(data[1]))*(width-1-vpX(data[1]))+vpY(data[2]));
            } else if (mouseY!=mouseX){
              line(vpX(data[1]),0,mouseX,height-1); 
            }
          }
      }
      break;
  }

  //framerate
  fill(0);
  textAlign(RIGHT, BOTTOM);
  textSize(8);
  text(frameRate+" ", width, height);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  float factor = -e/10+1;
  if (factor!=1) {
    scale.mult(factor);
    PVector newPos = new PVector(scX(mouseX), scY(mouseY));
    newPos.sub(mousePos);
    center.sub(newPos);
    vis.updateVisualizer();
  }
}
  
void mouseDragged() {
  //move center point on dragg
  center.x -= (mouseX-pmouseX)/scale.x;
  center.y += (mouseY-pmouseY)/scale.y;
  vis.updateVisualizer();
}

void mouseClicked() {
  switch(menu.getActionType()) {
    case 0://draw
      float charge = (menu.getMenuObject("draw/charge").getValue()==0 ? Constant.Electron.CHARGE : Constant.Proton.CHARGE);
      float mass = (menu.getMenuObject("draw/charge").getValue()==0 ? Constant.Electron.MASS : Constant.Proton.MASS);
      switch(menu.getMenuObject("draw/shape").getValue()){
        case 0://point charge
          sim.addObject(new Point(new PVector(mousePos.x, mousePos.y), mass, charge));
          menu.resetData();
          break;
        case 1://charge rod
          float[] menuData = menu.getData();
          if(menuData[0]==1){
            sim.addObject(new Rod(new PVector(menuData[1],menuData[2]),mousePos.copy(),mass,charge));
            menu.resetData();
            menuData[0]=-1;
          }
        case 2://infinite rod
          menuData = menu.getData();
          if (menuData[0]==0) {
            menuData[0]++;
            menuData[1]=mousePos.x;
            menuData[2]=mousePos.y;
          } else if(menuData[0]==1){
            menuData[0]=0;
            if(menuData[1] == mousePos.x && menuData[2] == mousePos.y){//if same point draw vertical line
              menuData[2]-=1;
            }
            sim.addObject(new Rod(PVector.add(new PVector(menuData[1],menuData[2]),mousePos).div(2),PVector.sub(mousePos,new PVector(menuData[1],menuData[2])).heading(),mass,charge));
            menu.resetData();
          } else {
            menuData[0]=0;
          }
          break;
      }
      break;
  }
}

void mainKeyPressed(char altKey, int altKeyCode){key=altKey; keyCode=altKeyCode; keyPressed();}
void keyPressed() {
  /*
    Arrow Keys - Translate Viewport
    PageUp/Dn  - Scale Viewport
    'o'        - Center Viewport to (0,0)
    
    TAB   - Cycle selected mode
    SPACE - Toggle menu visibility
    'd'   - Set menu to draw mode / cycle selected shape
    'c'   - [menu.getActionType==0] flip charge
    'f'   - Set menu to filter mode / cycle filter type
    'v'   - [menu.getActionType==2] cycle quality
    
    DELETE/BACKSPACE - reset current menu action / [menu.getActionType==0] delete most recent object
  */
  if (key==CODED) {
    switch(keyCode) {
    case UP:
      center.y+=2/scale.y;
      vis.updateVisualizer();
      break;
    case DOWN:
      center.y-=2/scale.y;
      vis.updateVisualizer();
      break;
    case RIGHT:
      center.x+=2/scale.x;
      vis.updateVisualizer();
      break;
    case LEFT:
      center.x-=2/scale.x;
      vis.updateVisualizer();
      break;
    case 33://PAGE UP
      scale.mult(1.05);
      vis.updateVisualizer();
      break;
    case 34://PAGE DOWN
      scale.mult(0.95);
      vis.updateVisualizer();
      break;
      
    //case SHIFT:
    //  sim.displayElectricField += 0.1;
    //  if(sim.displayElectricField>0.1) sim.displayElectricField = -0.1;
    //  break;
    }
  } else {
    switch(Character.toLowerCase(key)) {
      case TAB:
        menu.setActionType(menu.getActionType()+1);
        break;
      case ' ':
        menu.setVisible(!menu.isVisible());
        break;
      
      case 'd':
        if(menu.getActionType()==0){
          menu.getMenuObject("draw/shape").setValue(menu.getMenuObject("draw/shape").getValue()+1);
        }
        else{
          menu.setActionType(0);
        }
        break;
      case 'c':
        if(menu.getActionType()==0){
          menu.getMenuObject("draw/charge").setValue(menu.getMenuObject("draw/charge").getValue()+1);
        }
        break;
        
      case 'f':
        if(menu.getActionType()==2){
          menu.getMenuObject("filter/type").setValue(menu.getMenuObject("filter/type").getValue()+1);
        }
        else{
          menu.setActionType(2);
        }
        break;
      case 'v':
        if(menu.getActionType()==2){
          menu.getMenuObject("filter/definition").setValue(menu.getMenuObject("filter/definition").getValue()+1);
        }
        break;
      
      case 'o'://recenter origin
        center.set(0, 0);
        vis.updateVisualizer();
        break;
        
      case DELETE:
      case BACKSPACE:
        if(!menu.resetData()){
          switch(menu.getActionType()){
            case 0:
              sim.removeObject();
              break;
          }
        }
        break;
        
        
      //misc
      case 'r':
        randomizeViewport(10);
        break;
    }
  }
}
