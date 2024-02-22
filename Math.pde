/*
  Tomaz Chevres '24
  AP Physics C - Electricity & Magnetism
  Simulation
*/

//General commonly used Math functions

//Convert a simulation coordinate to a viewport px coordinate
public PVector vp(PVector sc){
  return new PVector(vpX(sc.x),vpY(sc.y));
}
public PVector vp(float scX, float scY){
  return new PVector(vpX(scX),vpY(scY));
}
public float vpX(float scX){
  return scale.x*(scX-center.x)+width/2;
}
public float vpY(float scY){
  return scale.y*(center.y-scY)+height/2;
}

//Convert a viewport px to a simulation coordinate
public PVector sc(PVector vp){
  return new PVector(scX(vp.x),scY(vp.y));
}
public PVector sc(float vpX, float vpY){
  return new PVector(scX(vpX),scY(vpY));
}
public float scX(float vpX){
  return center.x+(vpX - width/2)/scale.x;
}
public float scY(float vpY){
  return center.y-(vpY - height/2)/scale.y;
}


public float log10 (float x) {
  return (log(x) / log(10));
}

public float roundMultiple(float val, float mult){
  return round(val / mult) * mult;
}


//return exponent of the largest/smalles order of magnitude completely visible and discrete in the current simulation viewport
public PVector minVisibleMagnitude(){
  return new PVector(ceil(log10(1/scale.x)),floor(log10(1/scale.y)));
}
public PVector maxVisibleMagnitude(){
  return new PVector(floor(log10(0.5*width/scale.x)),floor(log10(0.5*height/scale.y)));
}
