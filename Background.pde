/*
  Tomaz Chevres '24
  AP Physics C - Electricity & Magnetism
  Simulation
*/

//draws the gridAxis and tickmarks
void drawGridAxis() {
  //PVector min = sc(0,height);
  //PVector max = sc(width,0);
  stroke(Color.STROKE);
  fill(Color.STROKE);
  line(0, vpY(0), width, vpY(0));
  line(vpX(0), 0, vpX(0), height);

  //println("Min: ",min);
  //println("Max: ",max);
  
  line(vpX(1),vpY(0)-10,vpX(1),vpY(0)+10);
  line(vpX(0)-10,vpY(1),vpX(0)+10,vpY(1));
  
  line(vpX(10),vpY(0)-10,vpX(10),vpY(0)+10);
  line(vpX(0)-10,vpY(10),vpX(0)+10,vpY(10));
  
}

String superScript(String str){
  char[] sub = new char[]{'⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','⁻'};
  String out = "";
  for(int i=0; i<str.length(); i++){
    char c = str.charAt(i);
    if(0<=c-'0' && c-'0'<10){
      out+=sub[c-'0'];
    } else if(c=='-'){
      out+="⁻";
    } else {
      out+=c;
    }
  }
  return out;
}
