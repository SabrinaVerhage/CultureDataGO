
class PointImage {
 
  //images:
  //schooltassen
  //erfgoed gelderland
  //cultureel erfgoed
  
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
  
  PShape plane;
  PShape sphere;
  
  final int num;
  final int dataset;
  final String text;
  
  int s_ground;
  float lifespan = 1000;
    
  float transparency;
  
  PointImage(PVector l, int n, int d, String t) { //add string
    
    location = l.get(); 
    num = n;
    dataset = d;
    text = t;
    
    velocity = new PVector(0, 0, random(12, 16));
    srotation = new PVector(random(360), random(360), random(360));
  
    catchDelta = new PVector();
    
    switch(dataset) {
      case 1:
        displace01[num].set("displaceStrength", 0.5);
        displace01[num].set("colorMap", textures01[num]);
        displace01[num].set("displacementMap", dtextures01[num]);
        break;
      case 2:
        displace02[num].set("displaceStrength", 0.5);
        displace02[num].set("colorMap", textures02[num]);
        displace02[num].set("displacementMap", dtextures02[num]);
        break;
      case 3:
        displace03[num].set("displaceStrength", 0.5);
        displace03[num].set("colorMap", textures03[num]);
        displace03[num].set("displacementMap", dtextures03[num]);
        break;
    }
    
    plane = createPlane(6, 6);
    
  }
  
  PointImage(int n, int d, String t, PVector sr, PVector cd, int s_g) {
    
    num = n;
    dataset = d;
    text = t;
    
    srotation = sr;
    catchDelta = cd;
    s_ground = s_g;
    
    switch(dataset) {
      case 1:
        displace01[num].set("displaceStrength", 0.5);
        displace01[num].set("colorMap", textures01[num]);
        displace01[num].set("displacementMap", dtextures01[num]);
        break;
      case 2:
        displace02[num].set("displaceStrength", 0.5);
        displace02[num].set("colorMap", textures02[num]);
        displace02[num].set("displacementMap", dtextures02[num]);
        break;
      case 3:
        displace03[num].set("displaceStrength", 0.5);
        displace03[num].set("colorMap", textures03[num]);
        displace03[num].set("displacementMap", dtextures03[num]);
        break;
    }
    
    plane = createPlane(6, 6);
    
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
  
    if(state == 1) {
      noFill();
      if(blackground) stroke(200, transparency);
      else stroke(50, transparency);
      strokeWeight(6);
      pushMatrix();
      translate(location.x, location.y, location.z);
      ellipse(-30, -15, vizerSize*2, vizerSize*2);
      popMatrix();
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
      
//ARGH HATE THIS SCALE STUFF SO CONFUSING
      pushMatrix();
      if(state == 5) scale(0.005);
      pushMatrix();

      //dataset with text...
      if(dataset == 3) {
        pushMatrix();
        hint(DISABLE_DEPTH_TEST);
        if(state == 5) scale(0.02); //1/5 similar to the Image class

        //TEXT
        if(blackground) fill(200);
        else fill(50);
        //textSize(35);
        textFont(TheFont, 35);
        textAlign(CENTER);
        text(text, 0, 0);
        
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
      } 
      
      rotateX(srotation.x);
      rotateY(srotation.y);
      rotateZ(srotation.z); 
      
      if(state == 5) scale(50);
      else scale(250);
  
      switch(dataset) {
        case 1:
          shader(displace01[num]);
          break; 
        case 2:
          shader(displace02[num]);
          break;
        case 3:
          shader(displace03[num]);
          break;
      }
      
      shape(plane);
  
      popMatrix();
      popMatrix();
      resetShader();
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
  
  
  // custom method to create a PShape plane by Amnon Owed
  PShape createPlane(int xsegs, int ysegs) {
  
    // STEP 1: create all the relevant data
    
    ArrayList <PVector> positions = new ArrayList <PVector> (); // arrayList to hold positions
    ArrayList <PVector> texCoords = new ArrayList <PVector> (); // arrayList to hold texture coordinates
  
    float usegsize = 1 / (float) xsegs; // horizontal stepsize
    float vsegsize = 1 / (float) ysegs; // vertical stepsize
  
    for (int x=0; x<xsegs; x++) {
      for (int y=0; y<ysegs; y++) {
        float u = x / (float) xsegs;
        float v = y / (float) ysegs;
  
        // generate positions for the vertices of each cell (-0.5 to center the shape around the origin)
        positions.add( new PVector(u-0.5, v-0.5, 0) );
        positions.add( new PVector(u+usegsize-0.5, v-0.5, 0) );
        positions.add( new PVector(u+usegsize-0.5, v+vsegsize-0.5, 0) );
        positions.add( new PVector(u-0.5, v+vsegsize-0.5, 0) );
  
        // generate texture coordinates for the vertices of each cell
        texCoords.add( new PVector(u, v) );
        texCoords.add( new PVector(u+usegsize, v) );
        texCoords.add( new PVector(u+usegsize, v+vsegsize) );
        texCoords.add( new PVector(u, v+vsegsize) );
      }
    }
  
    // STEP 2: put all the relevant data into the PShape
  
    textureMode(NORMAL); // set textureMode to normalized (range 0 to 1);
    
    PShape mesh = createShape(); // create the initial PShape
    mesh.beginShape(QUADS); // define the PShape type: QUADS
    mesh.noStroke();
    //mesh.stroke(255);
    switch(dataset) {
      case 1:
        mesh.texture(textures01[num]); // set a texture to make a textured PShape
        break;
      case 2:
        mesh.texture(textures02[num]);
        break;
      case 3:
        mesh.texture(textures03[num]);
        break;
    }
    // put all the vertices, uv texture coordinates and normals into the PShape
    for (int i=0; i<positions.size(); i++) {
      PVector p = positions.get(i);
      PVector t = texCoords.get(i);
      mesh.vertex(p.x, p.y, p.z, t.x, t.y);
    }
    mesh.endShape();
  
    return mesh; // our work is done here, return DA MESH! ;-)
  }
  
}