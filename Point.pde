
class Point {
 
  //just data:
  //schooltassen
  //zeeuwsarchief
  //Taalunie
    
  int state = 0;
  //state 0 = normal
  //state 1 = in vizer
  //state 2 = caught
  //state 3 = show
  //state 4 = hide & die
  //state 5 = world
  
  PVector location;
  PVector velocity;
  PVector srotation;
  
  PVector catchDelta;
  
  final boolean draw;
  final PVector size;
  final String text;
  
  int s_ground;
  float lifespan = 1000;
  
  float transparency;
  
  Point(PVector l, PVector s, String t, boolean d) {
    
    location = l.get(); 
    text = t;
    size = s.get();
    draw = d;
    velocity = new PVector(0, 0, random(12, 16));
    srotation = new PVector(random(360), random(360), random(360));
    //size = new PVector(random(50, 250), random(50, 250), random(50, 250));
  
    catchDelta = new PVector();
    
  }
  
  Point(PVector s, PVector sr, String t, boolean d, PVector cd, int s_g) {
    //contstructor for loading saved points
    size = s;
    srotation = sr;
    text = t;
    draw = d;
    catchDelta = cd;
    s_ground = s_g;
    changeState(5);
  }
  
  void update() {
    switch(state) {
      case 0:
      case 1:
        lifespan -= 1;
        transparency = map(lifespan, 1500, 1100, 0, 255);
        //srotation.add(rotation);
        location.add(velocity);
        
        PVector act_catchLocation = new PVector(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z);
        catchDelta = PVector.sub(location,act_catchLocation); 
        break;
      case 2:
      case 3:
        //do none of that
        break;
      case 4:
        lifespan -= 1;
        break;  
      case 5:
        transparency = 255;
        break;
      default:
        break;
    }
  }   

  boolean isDead() {
    if(lifespan < 0) return true;
    else return false;
  }
  
  
  void display() {
    
    if(!draw) {
      if(state == 1) {
        noFill();
        if(blackground) stroke(200, transparency);
        else stroke(50, transparency);
        strokeWeight(6);
        pushMatrix();
        translate(location.x, location.y, location.z);
        ellipse(-30, -15, vizerSize, vizerSize);
        popMatrix();
      } 
    }
        
    pushMatrix();
    switch(state) {
      case 0:
      case 1:
        translate(location.x, location.y, location.z);
        break;
      case 2:
        //ideally it would be in its last location relative to the catchlocation?
        translate(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z);
        translate(catchDelta.x, catchDelta.y, catchDelta.z);
        break; 
      case 3:
        translate(width/2, height/2, 0);
        rotateY(frameCount*0.005);
        translate(catchDelta.x, catchDelta.y, catchDelta.z);
        break;
      case 5:
        translate(camLocation.x, camLocation.y, camLocation.z);
        translate(catchDelta.x, catchDelta.y, catchDelta.z);
        rotateY(rotateWorld);

        PVector p = ico.positions.get(s_ground);
        scale(500);
        translate(p.x, p.y, p.z);
        

        break;
      default:
        break;
    }
    
    //don't show saved data during collection
    if((GSTATE == 3 && state != 5) || GSTATE != 3) {
      pushMatrix();
      if(state == 5) scale(0.05);
      pushMatrix();
      if(state == 5) scale(0.02); //1/5 similar to the Image class
      
      hint(DISABLE_DEPTH_TEST);
      
      //TEXT
      if(blackground) fill(200);
      else fill(50);
      //textSize(35);
      textFont(TheFont, 35);
      if(draw) textAlign(CENTER);
      else textAlign(LEFT);
      text(text, 0, 0);
      
      hint(ENABLE_DEPTH_TEST);
   
      if(draw) {
        rotateX(srotation.x);
        rotateY(srotation.y);
        rotateZ(srotation.z); 
        
        noFill();
        if(state == 1) strokeWeight(8);
        else strokeWeight(3);
        if(blackground) stroke(200, transparency);
        else stroke(50, transparency);
        box(size.x, size.y, size.z);
      } else {
        if(blackground) fill(255);
        else fill(0);
        noStroke();
        translate(-30, -15, 0);
        pushMatrix();
        scale(10);
        shape(bol);
        popMatrix();
      }
      
      // pop* pop* pop*
      popMatrix();
      popMatrix();
    } //end if GSTATE == 3 && state != 5
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
          caughtCount++;
          break;
        case 3:
          break;
        case 4:
          lifespan = 0;
          break;
        case 5:
          break;
        default:
          break;
      } 
    }
    state = newState;
  }
  
}