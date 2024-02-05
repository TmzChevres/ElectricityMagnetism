//colors
public static class Color {
  public final static color BACKGROUND = #CCCCCC;
  public final static color STROKE = #000000;

  public final static color CHARGE_POS = #FF0000;
  public final static color CHARGE_NEU = #666666;
  public final static color CHARGE_NEG = #0000FF;

  public final static color FIELD_LINE = #FF8000;

  public final static class Menu {
    public final static color UNSELECTED = #666666;
    public final static color SELECTED = #CCCCCC;
    public final static color BACKGROUND = #CCCCCC;
    public final static color TEXT = #333333;
  }

  public static color chargeColor(float charge) {
    if (charge<0) return Color.CHARGE_NEG;
    if (charge>0) return Color.CHARGE_POS;
    else return Color.CHARGE_NEU;
  }
}



public static class Constant {
  //fundamental particles
  public static class Proton {
    public final static float MASS = 1.67e-27; // kg
    public final static float CHARGE = 1.60e-19; // C
  }
  public static class Neutron {
    public final static float MASS = 1.67e-27; // kg
    public final static float CHARGE = 0; // C
  }
  public static class Electron {
    public final static float MASS = 9.11e-31; // kg
    public final static float CHARGE = -1.60e-19; // C
  }

  //speed of light
  public final static float C = 3.00e8; // m/s2

  //universal gravitational constant
  public final static float G = 6.67e-11; //(N*m2)/kg2

  //Vacumm permittivity ɛ0
  public final static float e0 = 8.85e-12; // C2/(N*m2)

  //Coulomb's law constant = 1/(4*PI*ɛ0)
  public final static float k =  9.0e9; // (N*m2)/C2
}

void randomizeViewport(int maxObjects) {
  sim.clearObjects();
  for (int i=0; i<random(1, maxObjects); i++) {
    int shape = (int)random(0, 3);
    float charge = Constant.Electron.CHARGE*(Math.random()<0.5?-1:1);
    float mass = random(Constant.Electron.MASS, Constant.Proton.MASS);
    PVector pos = new PVector(random(scX(0), scX(width)), random(scY(height), scY(0)));
    switch(shape) {
    case 0://point charge
      sim.addObject(new Point(pos, mass, charge));
      break;
    case 1:
      sim.addObject(new Rod(pos, random(-PI/2, PI/2), mass, charge));
      break;
    case 2:
      sim.addObject(new Rod(pos, random(-PI/2, PI/2), random(0, height/scale.y), mass, charge));
    }
  }
}


//Thread that loops at regular intervals
class LoopThread extends Thread {
  private boolean active;
  private float frameRate; // Frames per second

  LoopThread(float frameRate) {
    active = false;
    this.frameRate = frameRate;
  }

  void startLoop() {
    active = true;
    super.start();
  }

  void run() {
    while (active) {
      long startTime = millis();//long to prevent ovverflow error(s) potential???
      execute();
      long executionTime = millis() - startTime;
      int sleepTime = Math.max(0, (int) (1000.0 / frameRate - executionTime));
      delay(sleepTime);
    }
  }


  void execute() {
    System.out.println("Executing...");
  }

  boolean isActive() {
    return active;
  }

  void stopLoop() {
    active = false;
    interrupt();
  }
}
