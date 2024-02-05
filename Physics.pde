/*
  Tomaz Chevres '24
 AP Physics C - Electricity & Magnetism
 Simulation
 */

//Physics Engine
public class Physics {
  public ArrayList<PhysicsObject> objects;

  public Physics() {
    objects = new ArrayList<PhysicsObject>();
  }

  public boolean addObject(PhysicsObject o) {
    return objects.add(o);
  }
  public PhysicsObject removeObject(int i){
    if(0<i && i<objects.size()) return objects.remove(i);
    else return null;
  }
  public PhysicsObject removeObject(){//remove last object by default
    if(objects.size()>0) return objects.remove(objects.size()-1);
    else return null;
  }
  
  public void clearObjects(){
    objects = new ArrayList<PhysicsObject>();
  }

  public void draw() {
    //draw objects
    for (PhysicsObject o : objects) {
      o.draw();
    }
  }


  //DRAW ELECTRIC FIELD
  //http://online.cctt.org/physicslab/content/phyapc/lessonnotes/Efields/EchargedRods.asp
  public PVector getElectricField(PVector loc) {
    PVector e = new PVector();
    for (PhysicsObject o : objects) {
      e.add(o.getElectricField(loc));
    }
    return e;
  }
  
  /*
  public void drawFieldLine(PVector start, int steps, float step){
    if(step<1/scale.x) step = 1/scale.x;
    stroke(Color.FIELD_LINE);
    PVector loc = start.copy();
    for(int i=0; i<steps; i++){
      
    }
  }*/
}


//classes
public abstract class PhysicsObject {
  public boolean lock;//lock object position

  public PVector pos;//object center of mass
  public float mass;//object mass
  public float charge;//object charge

  PhysicsObject(PVector pos, float mass, float charge) {
    this(pos, mass, charge, true);
  }
  PhysicsObject(PVector pos, float mass, float charge, boolean lock) {
    this.pos = pos.copy();
    this.mass=mass;
    this.charge=charge;
    this.lock=lock;
  }

  //return the mass of the object
  public float getMass() {
    return mass;
  }

  //return the charge of the object
  public float getCharge() {
    return charge;
  }

  //return the electric field at a poing
  public abstract PVector getElectricField(PVector loc);

  public abstract void draw();
}





public class Point extends PhysicsObject {
  //constructors
  Point(PVector pos, float mass, float charge) {
    this(pos, mass, charge, false);
  }
  Point(PVector pos, float mass, float charge, boolean lock) {
    super(pos, mass, charge, lock);
  }

  public PVector getElectricField(PVector loc) {
    PVector r = new PVector(loc.x-pos.x, loc.y-pos.y);
    float mag = (Constant.k*charge)/(r.mag()*r.mag());
    r.normalize();
    r.mult(mag);
    return r;
  }

  public void draw() {
    fill(Color.chargeColor(charge));
    noStroke();
    ellipse(vpX(pos.x), vpY(pos.y), 5, 5);
  }
}

public class Rod extends PhysicsObject {
  //inherited super.charge represents ***CHARGE DENSITY***
  public float length;
  public float angle;

  //rods are always locked position
  Rod(PVector p1, PVector p2, float mass, float chargeDensity) {
    this(PVector.add(p1, p2).div(2), PVector.sub(p2, p1).heading(), PVector.sub(p2, p1).mag(), mass, chargeDensity);
  }
  Rod(PVector pos, float angle, float length, float mass, float chargeDensity) {
    super(pos, mass, chargeDensity, true);
    this.length=length;
    setAngle(angle);
    println(angle);
  }
  //INFINITE ROD --- charge=>charge density, length = infinity
  Rod(PVector pos, float angle, float mass, float chargeDensity) {
    super(pos, mass, chargeDensity, true);
    length = Float.POSITIVE_INFINITY;
    setAngle(angle);
  }
  
  public void setAngle(float theta){
    if(theta>PI/2) theta = theta-PI;
    if(theta<=-PI/2) theta = theta+PI;
    angle = theta;
  }

  public boolean isInfinite() {
    return Float.isInfinite(length);
  }

  public float getChargeDensity() {
    if (isInfinite()) return charge;
    else return charge/length;
  }

  public float[] getBounds(){//returns bounds of the rod {x1,y1,x2,y2}
    if (isInfinite()) {
      if (angle==PI/2) {
        return new float[]{pos.x, Float.NEGATIVE_INFINITY, pos.x, Float.POSITIVE_INFINITY};
      } else if (angle==0) {
        return new float[]{Float.NEGATIVE_INFINITY, pos.y, Float.POSITIVE_INFINITY, pos.y};
      } else return new float[]{Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY};
    } else return new float[]{pos.x-length*cos(angle)/2, pos.y-length*sin(angle)/2, pos.x+length*cos(angle)/2, pos.y+length*sin(angle)/2};
  }

  public PVector getElectricField(PVector loc) {
    //In standard form ax+by+c=0 (assuming b=1)
    //    y = tan(angle)*x -tan(angle)*x1+y1
    float a = -tan(angle);
    float c = tan(angle)*pos.x-pos.y;
    float dist = abs(a*loc.x+loc.y+c)/sqrt(a*a+1);
    PVector intersect = new PVector((loc.x-a*loc.y-a*c)/(a*a+1),(a*(-loc.x+a*loc.y)-c)/(a*a+1));
    //fill(0);
    //stroke(0);
    //ellipse(vpX(intersect.x),vpY(intersect.y),5,5);
    if (isInfinite()) {
      //println(a,1,c,dist, new PVector(loc.x - (loc.x-a*loc.y-a*c)/(a*a+1),loc.y - (a*(-loc.x+a*loc.y)-c)/(a*a+1)));
      return new PVector(loc.x - intersect.x,loc.y - intersect.y).limit(2*Constant.k*charge/dist);
    } else {
      float[] bounds = getBounds();
      float[] boundsDelta = getBounds();
      boundsDelta[0]-=intersect.x;
      boundsDelta[1]-=intersect.y;
      boundsDelta[2]-=intersect.x;
      boundsDelta[3]-=intersect.y;
      int direction = (angle==PI/2?(loc.y>pos.y?1:-1):(loc.y>intersect.y?1:-1));
      int intersection = 0;// -1 if intersect is before seg, 0 if on, 1 if after
      if(angle == PI/2){
        if(intersect.y < bounds[1]) intersection = -1;
        else if(intersect.y > bounds[3]) intersection = 1;
      }
      else{
        if(intersect.x < bounds[0]) intersection = -1;
        else if(intersect.x > bounds[2]) intersection = 1;
      }
      float[] l = new float[]{(intersection>=0?-1:1)*sqrt(boundsDelta[0]*boundsDelta[0]+boundsDelta[1]*boundsDelta[1]),(intersection>0?-1:1)*sqrt(boundsDelta[2]*boundsDelta[2]+boundsDelta[3]*boundsDelta[3])};
      
      //x&y magnitudes of the field (relative to the rod)
      float eY = direction*(Constant.k*charge/dist) * (l[1]/sqrt(l[1]*l[1]+dist*dist) - l[0]/sqrt(l[0]*l[0]+dist*dist));
      float eX = (Constant.k*charge) * (1/sqrt(l[1]*l[1]+dist*dist) - 1/sqrt(l[0]*l[0]+dist*dist));
      //float eX = 0;
      return new PVector(eX,eY).rotate(angle);
    }
  }

  public void draw() {
    stroke(Color.chargeColor(charge));
    strokeWeight(3);
    if (!isInfinite()) {
      float[] bounds = getBounds();
      line(vpX(bounds[0]), vpY(bounds[1]), vpX(bounds[2]), vpY(bounds[3]));
      //ellipse(vpX(bounds[0]),vpY(bounds[1]),5,5); //indicate start point
    } else {
      if (angle==PI/2 || angle==-PI/2) {
        line(vpX(pos.x), 0, vpX(pos.x), height-1);
      } else {
        line(0, -tan(angle)*(0-vpX(pos.x))+vpY(pos.y), width-1, -tan(angle)*(width-1-vpX(pos.x))+vpY(pos.y));
      }
    }
    strokeWeight(1);
  }
}
