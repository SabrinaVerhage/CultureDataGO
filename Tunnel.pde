
class Tunnel {
 
  //polygon tunnel elements
  
  int state = 0;
  //state 0 = normal
  //state 1 = in vizer
  //state 2 = caught
  
  PVector location;
  PVector velocity;
        
  float lifespan = 1500;
  float transparency;
  float weight;
  
  int[] savedMyodata = new int[8];

  Tunnel(PVector l, float w, PVector v) {
    location = l.get(); 
    weight = w;
    velocity = v.get();
    //velocity = new PVector(0, 0, random(12, 16));  
    arrayCopy(smoothMyodata, savedMyodata); //why does it keep updating everyframe?
  }
  
  void update() {
    lifespan -= 1;
    transparency = map(lifespan, 1500, 1100, 0, 255);
    location.add(velocity);
  }
  
  boolean isDead() {
    if(lifespan < 0) return true;
    else return false;
  }
  
  void display() {

    if(blackground) stroke(200, transparency);
    else stroke(50, transparency);
    strokeWeight(weight);
    noFill();

    pushMatrix();
    translate(location.x, location.y, location.z);
    rotateZ(rotateWorld);
    
    dataHexagon(savedMyodata);
    
    popMatrix();
  }
  
  void changeState(int newState) {
    if(state!=newState) {
      switch(newState) {
        case 0: 
          break;
        case 1:
          break;
        case 2:
          break;
        default:
          break;
      } 
    }
    state = newState;
  }
   
}




void dataHexagon(int[] data) {
  if(MyoConnected) {
    
    beginShape();
    vertex(cos(radians(45)) * (universeHeight+data[0]), sin(radians(45)) * (universeHeight+data[0]));
    vertex(cos(radians(90)) * (universeHeight+data[1]), sin(radians(90)) * (universeHeight+data[1]));
    vertex(cos(radians(135)) * (universeHeight+data[2]), sin(radians(135)) * (universeHeight+data[2]));
    vertex(cos(radians(180)) * (universeHeight+data[3]), sin(radians(180)) * (universeHeight+data[3]));
    vertex(cos(radians(225)) * (universeHeight+data[4]), sin(radians(225)) * (universeHeight+data[4]));
    vertex(cos(radians(270)) * (universeHeight+data[5]), sin(radians(270)) * (universeHeight+data[5]));
    vertex(cos(radians(315)) * (universeHeight+data[6]), sin(radians(315)) * (universeHeight+data[6]));
    vertex(cos(radians(360)) * (universeHeight+data[7]), sin(radians(360)) * (universeHeight+data[7]));
    endShape(CLOSE);
    
  } else if(LeapConnected) {
    
    beginShape();
    vertex(cos(radians(45)) * universeHeight, sin(radians(45)) * universeHeight);
    vertex(cos(radians(90)) * universeHeight, sin(radians(90)) * universeHeight);
    vertex(cos(radians(135)) * universeHeight, sin(radians(135)) * universeHeight);
    vertex(cos(radians(180)) * universeHeight, sin(radians(180)) * universeHeight);
    vertex(cos(radians(225)) * universeHeight, sin(radians(225)) * universeHeight);
    vertex(cos(radians(270)) * universeHeight, sin(radians(270)) * universeHeight);
    vertex(cos(radians(315)) * universeHeight, sin(radians(315)) * universeHeight);
    vertex(cos(radians(360)) * universeHeight, sin(radians(360)) * universeHeight);
    endShape(CLOSE);
    
  } else {
    beginShape();
    vertex(cos(radians(45)) * universeHeight, sin(radians(45)) * universeHeight);
    vertex(cos(radians(90)) * universeHeight, sin(radians(90)) * universeHeight);
    vertex(cos(radians(135)) * universeHeight, sin(radians(135)) * universeHeight);
    vertex(cos(radians(180)) * universeHeight, sin(radians(180)) * universeHeight);
    vertex(cos(radians(225)) * universeHeight, sin(radians(225)) * universeHeight);
    vertex(cos(radians(270)) * universeHeight, sin(radians(270)) * universeHeight);
    vertex(cos(radians(315)) * universeHeight, sin(radians(315)) * universeHeight);
    vertex(cos(radians(360)) * universeHeight, sin(radians(360)) * universeHeight);
    endShape(CLOSE);
  }
}