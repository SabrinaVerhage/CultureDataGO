
class Star {
 
  //polygon shaped objects/stars
  
  int state = 0;
  //state 0 = normal
  //state 1 = in vizer
  //state 2 = caught
  
  PVector location;
  PVector velocity;
  PVector srotation;
  PVector rotation;
    
  //PShape polygon;
    
  float lifespan = 1500;
  float size;
  float size_height;
  
  color[] randomColor = new color[4]; 
  float transparency;
  color noiseColor;
  color lifeColor;
  
  Star(PVector l) {
    location = l.get(); 
    velocity = new PVector(0, 0, random(12, 16));
    srotation = new PVector(random(360), random(360), random(360));
    rotation = new PVector(random(5)/1000, random(5)/1000, random(5)/1000);
    
    noiseDetail(3,0.5);
    size = map(noise(location.x, location.y, location.z), 0, 1, 0, 100);
    size_height = map(noise(location.x, location.y, location.z), 0, 1, 1, 4);
    noiseColor = color(map(noise(location.x, location.y, location.z), 0, 1, 0, 50));

    randomColor[0] = color(random(200, 255), random(200, 255), random(200, 255)); 
    for (int i=1; i<4; i++) {
      randomColor[i] = color(random(200, 255), random(100, 255), random(100, 255));
    }
    
  }
  
  void update() {
    lifespan -= 1;
    transparency = map(lifespan, 1500, 1100, 0, 255);
    srotation.add(rotation);
    location.add(velocity);
  }
  
  boolean isDead() {
    if(lifespan < 0) return true;
    else return false;
  }
  
  void display() {

    strokeWeight(3);

    pushMatrix();
    translate(location.x, location.y, location.z);

    rotateX(srotation.x);
    rotateY(srotation.y);
    rotateZ(srotation.z);
        
//draw shape
    beginShape(TRIANGLES);
    
    if(state == 1) {
      if(blackground) stroke(200, transparency);
      else stroke(50, transparency);
    } else {
      noStroke(); 
    }
    
    fill(randomColor[0], transparency);
    vertex(0, size, 0);
    fill(randomColor[2], transparency);
    vertex(-size, -size, 0);
    fill(randomColor[3], transparency);
    vertex(size, -size, 0);
    
    fill(randomColor[1], transparency);
    vertex(0, 0, size*size_height);
    fill(randomColor[0], transparency);
    vertex(0, size, 0);
    fill(randomColor[2], transparency);
    vertex(-size, -size, 0);

    fill(randomColor[1], transparency);
    vertex(0, 0, size*size_height); 
    fill(randomColor[2], transparency);
    vertex(-size, -size, 0);
    fill(randomColor[3], transparency);
    vertex(size, -size, 0);

    fill(randomColor[1], transparency);
    vertex(0, 0, size*size_height);
    fill(randomColor[0], transparency);
    vertex(0, size, 0);
    fill(randomColor[3], transparency);
    vertex(size, -size, 0);
    endShape(); 
    
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