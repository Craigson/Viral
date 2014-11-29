class DropZone {
  
  //data
  float x;
  float y;
  float r;
  PVector checker;
  float r2, origR2;
  
  //constructor
  DropZone(float radius){
  
  r = radius;
  x = width/2;
  y = height - 50 - r;
  r2 = radius;
  origR2 = radius;
 
  }
  
  //methods
  void display(){
    noStroke();
    fill(255,50);
    ellipse(x,y,2*r,2*r);
    if (numberGrabbed == 1 && zoneIsOccupied == false){
      fill(0);
      strokeWeight(2);
      stroke(360,0,30);
      ellipse(x,y,2*r2,2*r2);
      r2 -= 3;
      if (r2 < 0){
        r2 = origR2;
      }
    }
    }
  
    
    void pulse(){
    }

  
  
}
