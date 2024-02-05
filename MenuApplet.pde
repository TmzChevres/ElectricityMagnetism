import java.util.Map;
import java.util.HashMap;

public class MenuApplet extends PApplet {
  public SelectorPanel mainSelector;
  public MenuGroup[] mainGroups; // used for drawing purposes
  public Map<String,MenuObject> menuMap;
  public float[] data;//temp store relavent values for actions

  public MenuApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(200, 400);
  }

  public void setup() {
    surface.setTitle("Menu");
    data = new float[10];
    
    mainSelector = new SelectorPanel(0, 0, width/4, height, true, "Draw\nCharges", "Edit", "Filters"){
      @Override
      public void mouseClicked() {
        if (x<mouseX && mouseX<x+w && y<mouseY && mouseY<y+h) {
          float dx = w/columns;
          float dy = h/ceil(1.0*labels.length/columns);
          for (int i=0; i<labels.length; i++) {
            float x = this.x+dx*(i%columns);
            float y = this.y+dy*(i/columns);
            if(x<mouseX && mouseX<x+dx && y<mouseY && mouseY<y+dy){
              select = i;
              resetData();
            }
          }
        }
      }
      @Override
      public void setValue(int val){
        if(val%labels.length!=select){
          select = val%labels.length;
          resetData();
        }
      }
    };
    
    menuMap = new HashMap<String,MenuObject>();
    menuMap.put("draw/charge",new SelectorPanel(0,height/16,0.75*width,height/8,false,"Negative","Positive"));
    menuMap.put("draw/shape",new SelectorPanel(0,height/16,0.75*width,height/4,2,"Point\nCharge","Charged\nRod","Infinite\nRod"));
    menuMap.put("filter/type",new SelectorPanel(0,height/16,0.75*width,height/8,false,"Electric\nField","Electric\nPotential"));
    menuMap.put("filter/definition",new SelectorPanel(0,height/16,0.75*width,height/8,3,"OFF","Low","High"));
    //menuMap.get("filter/definition").setValue(1);
    
    mainGroups = new MenuGroup[]{
      new MenuGroup(width/4,0,
        new MenuGroup(0,0,
          new MenuText("Charge",0.75*width/2,height/32,Color.Menu.TEXT),
          menuMap.get("draw/charge")
        ),
        new MenuGroup(0,height/4,
         new MenuText("Shape",0.75*width/2,height/32,Color.Menu.TEXT),
         menuMap.get("draw/shape")
        )
      ),
      null,
      new MenuGroup(width/4,0,
        new MenuGroup(0,0,
          new MenuText("Display Type",0.75*width/2,height/32,Color.Menu.TEXT),
          menuMap.get("filter/type")
        ),
        new MenuGroup(0,height/4,
          new MenuText("Quality",0.75*width/2,height/32,Color.Menu.TEXT),
          menuMap.get("filter/definition")
        )
      )
    };
  }

  public void draw() {
    background(Color.Menu.BACKGROUND);
    mainSelector.draw();
    if(0<=mainSelector.getValue() && mainSelector.getValue()<mainGroups.length && mainGroups[mainSelector.getValue()]!=null){
      mainGroups[mainSelector.getValue()].draw();
    }
    
    //dividing line
    stroke(Color.Menu.TEXT);
    line(mainSelector.w,0,mainSelector.w,height);
  }

  public void mouseClicked() {
    mainSelector.mouseClicked();
    if(0<=mainSelector.getValue() && mainSelector.getValue()<mainGroups.length && mainGroups[mainSelector.getValue()]!=null){
      mainGroups[mainSelector.getValue()].mouseClicked();
    }
  }
  
  public void keyPressed(){
    mainKeyPressed(key,keyCode);
  }

  public boolean isVisible(){
    return ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame().isVisible();
  }
  public void setVisible(boolean visible) {
    surface.setVisible(visible);
  }
  public void setLocation(int x, int y) {
    surface.setLocation(x, y);
  }
  
  public void setActionType(int i){
    mainSelector.setValue(i);
  }
  public int getActionType(){
    try{
    return mainSelector.getValue();
    } catch (Exception e){//???nullpointerexception possibility???
      println(e);
      return -1;
    }
  }
  
  public float[] getData(){
    return data;
  }
  public float getData(int i){
    return data[i];
  }
  public void setData(int i, float val){
    data[i] = val;
  }
  public boolean resetData(){//returns false if all values are already 0
    boolean reset = false;
    for(int i=0; i<data.length; i++){
      if(data[i]!=0) reset = true;
      data[i]=0;
    }
    return reset;
  }
  
  public MenuGroup getMenuGroup(int i){
    return mainGroups[i];
  }
  public MenuObject getMenuObject(String id){
    return menuMap.get(id);
  }



  //MENU OBJECTS----------------------------------------------------
  private abstract class MenuObject {
    public abstract void draw();
    public abstract void mouseClicked();
    public abstract void shiftPos(float x, float y);
    public int getValue(){
      return -1;
    };
    public void setValue(int val){};
  }
  private class MenuGroup extends MenuObject {
    MenuObject[] objects;
    public MenuGroup(float x, float y, MenuObject ... objects) {
      this.objects=objects;
      shiftPos(x, y);
    }
    public MenuGroup(MenuObject ... objects) {
      this.objects=objects;
    }

    public void draw() {
      for (MenuObject o : objects) {
        o.draw();
      }
    }
    public void mouseClicked() {
      for (MenuObject o : objects) {
        o.mouseClicked();
      }
    }
    public void shiftPos(float x, float y) {
      for (MenuObject o : objects) {
        o.shiftPos(x, y);
      }
    }
  }
  class SelectorPanel extends MenuObject {
    float x, y, w, h;
    int columns;
    String[] labels;
    color selected, unselected;

    int select = 0;

    public SelectorPanel(float x, float y, float w, float h, boolean vertical, String ... labels) {
      this(x, y, w, h, new color[]{Color.Menu.SELECTED, Color.Menu.UNSELECTED}, vertical, labels);
    }
    public SelectorPanel(float x, float y, float w, float h, int cols, String ... labels) {
      this(x, y, w, h, new color[]{Color.Menu.SELECTED, Color.Menu.UNSELECTED}, cols, labels);
    }
    public SelectorPanel(float x, float y, float w, float h, color[] c, boolean vertical, String ... labels) {
      this(x, y, w, h, new color[]{Color.Menu.SELECTED, Color.Menu.UNSELECTED}, (vertical?1:labels.length), labels);
    }
    public SelectorPanel(float x, float y, float w, float h, color[] c, int cols, String ... labels) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.labels = labels;
      this.columns = cols;
      if (columns>labels.length) columns=labels.length;
      selected = c[0];
      unselected = c[1];
    }

    public void draw() {
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      stroke(unselected);
      float dx = w/columns;
      float dy = h/ceil(1.0*labels.length/columns);
      for (int i=0; i<labels.length; i++) {
        float x = this.x+dx*(i%columns);
        float y = this.y+dy*(i/columns);
        fill(i==select?selected:unselected);
        rect(x, y, dx, dy);
        fill(i==select?unselected:selected);
        text(labels[i], x+dx/2, y+dy/2);
      }
    }

    public void mouseClicked() {
      if (x<mouseX && mouseX<x+w && y<mouseY && mouseY<y+h) {
        float dx = w/columns;
        float dy = h/ceil(1.0*labels.length/columns);
        for (int i=0; i<labels.length; i++) {
          float x = this.x+dx*(i%columns);
          float y = this.y+dy*(i/columns);
          if(x<mouseX && mouseX<x+dx && y<mouseY && mouseY<y+dy){
            select = i;
          }
        }
      }
    }

    public void shiftPos(float dx, float dy) {
      x+=dx;
      y+=dy;
    }
    
    public int getValue(){
      return select;
    }
    public void setValue(int val){
      select = val%labels.length;
    }
  }
  private class MenuText extends MenuObject{
    String text;
    public float x,y;
    public color c;
    public float size;
    PFont font;
    
    public MenuText(String text, float x, float y, color c){
      this(text,x,y,null,-1,c);
    }
    public MenuText(String text, float x,float y,PFont font, float size, color c){
      this.text = text;
      this.x = x;
      this.y = y;
      this.font = font;
      this.size = size;
      this.c = c;
    }
    
    public void draw(){
      textAlign(CENTER,CENTER);
      //use defaults otherwise
      if(font!=null) textFont(font);
      if(size>=0) textSize(size);
      fill(c);
      text(text,x,y);
    }
    
    public void mouseClicked(){}
    
    public void shiftPos(float dx, float dy) {
      x+=dx;
      y+=dy;
    }
  }
}
