// ** by Sabrina Verhage ** 
// www.sabrinaverhage.com
// for Open Cultuur Data Lab www.opencultuurdata.nl

// ==> HI, SET THESE VALUES <==
//interaction based on Myo or LeapMotion?
//check if setup is set to fullscreen if required
boolean MyoConnected = false;
boolean LeapConnected = false;
boolean mute = false; //mute audio
boolean export = true; //turn off debug features for export

import peasy.*;
import de.voidplus.myo.*;
import de.voidplus.leapmotion.*;
import controlP5.*;

import beads.*;
import java.util.Arrays; 

//GAME STATES
int GSTATE = 0;
//GSTATE 0 = main view/start
//GSTATE 1 = introduction
//GSTATE 2 = game
//GSTATE 3 = end

//UI
ControlP5 cp5;

//CAMERA CONTROL
PeasyCam cam;
boolean peasycam = false;
PVector camLocation;

//AUDIO  
AudioContext ac;
SamplePlayer player;

//UNIVERSE STUFF
float universeWidth = 2000; 
float universeHeight = 1500;
float universeDepth = 8000;
boolean blackground = false;

PVector universeMax;
PVector universeMin;
int catchDist = 160;

//DATA
String curDate;
volatile boolean loading = false;
boolean saving = false;
boolean showData = true;
int selnum01, selnum02, selnum03, selnum04;
int seltex01, seltex02, seltex03;


//IMAGE DATA
final int numtextures01 = 18;
final PImage[] textures01 = new PImage[numtextures01];
final PImage[] dtextures01 = new PImage[numtextures01];
final PShader[] displace01 = new PShader[numtextures01];

final int numtextures02 = 456;
final PImage[] textures02 = new PImage[numtextures02];
final PImage[] dtextures02 = new PImage[numtextures02];
final PShader[] displace02 = new PShader[numtextures02];

final int numtextures03 = 100;
final PImage[] textures03 = new PImage[numtextures03];
final PImage[] dtextures03 = new PImage[numtextures03];
final PShader[] displace03 = new PShader[numtextures03];

//schooltassen
String[] lines01;
ArrayList<Float> hoog = new ArrayList<Float>();
ArrayList<Float> breed = new ArrayList<Float>();
ArrayList<Float> diep = new ArrayList<Float>();
ArrayList<String> materiaal = new ArrayList<String>();

//open beelden
String[] lines02;
ArrayList<String> title = new ArrayList<String>();

//zeeuwsarchief
String[] lines03;
ArrayList<String> geboorteInfo = new ArrayList<String>();

//monumenten
String[] lines04;
ArrayList<String> beschrijving = new ArrayList<String>();

//letterf
String[] lines05;
ArrayList<String> letterf = new ArrayList<String>();

////NIOD
//String[] lines06;
//ArrayList<String> twwoorlog = new ArrayList<String>();

//SAVED DATA
String[] savedLines01;
String[] savedLines02;
String[] savedLines03;

//FLOATING OBJECTS
ArrayList<Point> points;
ArrayList<PointImage> pointsI;
ArrayList<PointAnimation> pointsA;
ArrayList<Star> stars;
ArrayList<Tunnel> tunnels;

//INTERACTION
int GROUND = 0;
PVector navigation;
PVector catchLocation;
PVector catchWindow;
final int vizerSize = 200;
int caughtCount = 0;
Icosahedron ico;
float rotateWorld = 0;
PShape bol;
int testPos = 0; //for world mapping
float loadCentage = 0;
float ploadCentage = 0;

Myo myo;
PVector Myorientation;
int[] Myodata = new int[8];
int[] smoothMyodata = new int[8];
boolean caught; //for Myo vibrations

LeapMotion leap;
long leapTimer;
final int leapTime = 2000;

///////////TIMERS
long fadeTime;
final int fadeLength = 1000;
boolean goFade = false;
boolean fadeDone = false;
long introTime;
final int introLength = 4000;
long gameTime;
final int gameLength = 60000;
long saveTime;
final int saveLength = 8000;
long starTime;
final int starLength = 500;
long dataTime;
float datams;

//
PFont TheFont;


void settings() {
  //setup window size
  size(1920, 1080, P3D);
  //fullScreen(P3D,1);
  
  PJOGL.setIcon("data/icon.png");
}

void setup() {
 
  surface.setTitle("Culture Data GO");
  
  TheFont = createFont("Moon", 70);
  textFont(TheFont);
  //textMode(SHAPE); //makes it unbelievably slow
  
  hint(ENABLE_STROKE_PERSPECTIVE);
  
  //SETUP UI
  setupUI();
  
  //AUDIO
  ac = new AudioContext();
  // uncomment the right line for your platform
  // FOR WINDOWS:
  String audioFileName = sketchPath("") + "data\\tone.wav";
  // FOR MAC:
  //String audioFileName = sketchPath() + "/data/lullatone.wav";
  player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
  player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  Gain g = new Gain(ac, 2, 0.8);
  g.addInput(player);
  ac.out.addInput(g);
  if(!mute) ac.start();
  
  curDate = str(year()) + str(month()) + str(day());
  
  //LOAD DATA
  thread("loadData"); 
  //load data in a seperate thread
  //in the mean time show a 'loading' animation
  
  //CAMERA
  cam = new PeasyCam(this, 100);
  cam.setMaximumDistance(50000);
  camLocation = new PVector(width/2, height/2, 0);
  
  //INTERACTION
  if(MyoConnected) {
    myo = new Myo(this);
    myo.withEmg();
    myo.setLockingPolicy(Myo.LockingPolicy.NONE);
  } else if(LeapConnected) {
    leap = new LeapMotion(this); 
  }
  
  navigation = new PVector();
  catchLocation = new PVector(0, 0, 0);
  catchWindow = new PVector(universeWidth/5, universeHeight/5, universeDepth);
   
  points = new ArrayList<Point>();
  pointsI = new ArrayList<PointImage>();
  pointsA = new ArrayList<PointAnimation>();
  stars = new ArrayList<Star>();
  tunnels = new ArrayList<Tunnel>();
  
  ico = new Icosahedron(2);
  bol = createIcosahedron(1);
   
  datams = random(6000);  
  
  //STAGE/UNIVERSE SIZE
  universeMax = new PVector();
  universeMin = new PVector();
 
}


  int blurFactor = 3;
  float resizeFactor = 0.25;
  
// convenience method to create a smooth displacementMap from Amnon Owed
PImage imageToDisplacementMap(PImage img) {
  PImage imgCopy = img.get(); // get a copy so the original remains intact
  imgCopy.resize(int(imgCopy.width*resizeFactor), int(imgCopy.height*resizeFactor)); // resize
  if (blurFactor >= 1) { imgCopy.filter(BLUR, blurFactor); } // apply blur
  return imgCopy;
}

////////////////////////////////////////////////////////////////////
void draw() {
  
  //println(Runtime.getRuntime().totalMemory());
  
  if(!peasycam) {
    beginCamera();
    //camera();
    camera(width/2, height/2, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
    endCamera();
  }
  
  //BACKGROUND 
  if(blackground) background(0);
  else background(255);

  lights();  
  
  rotateWorld+=0.001;

  //draw stuff based on GAME STATE
  switch(GSTATE) {
    case 0:
      //loading
      // & click to start
      drawStage();
      drawData();
      if(LeapConnected) checkinteraction();
      if(!loading) fade(false); 
      break;
    case 1:
      //collect cultuurdata
      drawStage();
      drawIntroduction();
      if(millis()-introTime > introLength) changeState(2);
      fade(false); 
      break;
    case 2:
      //game
      drawStage();
      drawStars();
      drawTunnels();
      if(showData) collectData();
      drawVizer();
      interaction();

      if(millis()-gameTime > gameLength) changeState(3);
      break; 
    case 3:
      //collected cultuurdata
      drawStage();
      drawData();
      if(millis()-saveTime > saveLength) changeState(0);
      fade(false); 

      break; 
    default:
        break;
  }
  
  if(loading) {
    //draw loading animation
    if(blackground) background(0);
    else background(255);
    
    pushMatrix();
    noFill();
    translate(width/2, height/2);
    if(blackground) stroke(200);
    else stroke(50);
    strokeWeight(5);
    rotateZ(rotateWorld);
    beginShape();
    int val = 500;
    vertex(cos(radians(45)) * val, sin(radians(45)) * val);
    vertex(cos(radians(90)) * val, sin(radians(90)) * val);
    vertex(cos(radians(135)) * val, sin(radians(135)) * val);
    vertex(cos(radians(180)) * val, sin(radians(180)) * val);
    vertex(cos(radians(225)) * val, sin(radians(225)) * val);
    vertex(cos(radians(270)) * val, sin(radians(270)) * val);
    vertex(cos(radians(315)) * val, sin(radians(315)) * val);
    vertex(cos(radians(360)) * val, sin(radians(360)) * val);
    endShape(CLOSE);
    popMatrix();
    
    if(blackground) fill(200);
    else fill(50);
    noStroke();
    textSize(70);
    textAlign(CENTER);
    text("LOADING CULTURE DATA", width/2, height/2);
  }
  
  //DEBUG
//  println("points: " + points.size());
//  println("pointsI: " + pointsI.size());
//  println("pointsA: " + pointsA.size());
  
 
}

//////////////////////
void drawIntroduction() {
  
  if(blackground) fill(200);
  else fill(50);
  noStroke();
  textSize(45);
  textAlign(CENTER);
  text("IN A WORLD...", width/2, height/2);
  text("WHERE OPEN CULTURE DATA IS A PUBLIC GOOD", width/2, height/2+40);
  text("EVERYBODY IS ADDICTED TO", width/2, height/2+80);
  textSize(60);
  text("CULTURE DATA GO", width/2, height/2+140);
}

//////////////////////
void drawStage() {
  
  //DETERMINE STAGE
  universeMax.x = camLocation.x+universeWidth/2;
  universeMax.y = camLocation.y+universeHeight/2;
  universeMax.z = camLocation.z-universeDepth;
  
  universeMin.x = camLocation.x-universeWidth/2;
  universeMin.y = camLocation.y-universeHeight/2;
  universeMin.z = camLocation.z;
  
  noFill();
  if(blackground) stroke(200);
  else stroke(50);
  strokeWeight(1);
  
  if(!LeapConnected && !MyoConnected) {
    //instructions for interaction without Myo or Leapmotion
    if(blackground) fill(200);
    else fill(50);
    noStroke();
    textSize(35);
    textAlign(LEFT);
    
    switch(GSTATE) {
      case 0:
        text("Press [space] to begin", 20, 60);
        break;
      case 2:
        text("Use the arrow keys to navigate", 20, height-35);
        break;
      default:
        break;
    }
  }

  
//  //CAMERA
//  pushMatrix();
//  translate(camLocation.x, camLocation.y, camLocation.z);
//  box(100);
//  popMatrix();
  
  
  /*
  //STAGE
  //back wall  
  pushMatrix();
  translate(camLocation.x, camLocation.y, universeMax.z);
  rect(-universeWidth/2, -universeHeight/2, universeWidth, universeHeight);
  popMatrix();
  //left wall
  pushMatrix();
  translate(universeMin.x, camLocation.y, camLocation.z-universeDepth/2);
  rotateY(radians(90));
  rect(-universeDepth/2, -universeHeight/2, universeDepth, universeHeight);
  popMatrix();
  //right wall
  pushMatrix();
  translate(universeMax.x, camLocation.y, camLocation.z-universeDepth/2);
  rotateY(radians(90));
  rect(-universeDepth/2, -universeHeight/2, universeDepth, universeHeight);
  popMatrix();
  //ceiling
  pushMatrix();
  translate(camLocation.x, universeMax.y, camLocation.z-universeDepth/2);
  rotateX(radians(90));
  rect(-universeWidth/2, -universeDepth/2, universeWidth, universeDepth);
  popMatrix();
  //floor
  pushMatrix();
  translate(camLocation.x, universeMin.y, camLocation.z-universeDepth/2);
  rotateX(radians(90));
  rect(-universeWidth/2, -universeDepth/2, universeWidth, universeDepth);
  popMatrix();
  */
  
} 

//////////////////////
void drawVizer() {
  //VIZER for interaction
  if(blackground) stroke(200);
  else stroke(50);
  noFill();
  strokeWeight(3);
  
  pushMatrix();
  translate(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z);
  ellipse(0, 0, vizerSize, vizerSize);
  popMatrix(); 
}

//////////////////////
void drawStars() {
   
  if(millis()-starTime>starLength) {
    stars.add(new Star(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth))); 
    starTime = millis();
  }
  
  //ok so the for loop is backwards because of some remove actions
  for(int i = stars.size()-1; i >= 0; i--) {
    Star s = stars.get(i);
    
    float d = dist(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z, s.location.x, s.location.y, s.location.z);
    
    if(s.location.x < (camLocation.x+catchLocation.x)+catchWindow.x && 
    s.location.x > (camLocation.x+catchLocation.x)-catchWindow.x &&
    s.location.y < (camLocation.y+catchLocation.y)+catchWindow.y &&
    s.location.y > (camLocation.y+catchLocation.y)-catchWindow.y &&
    s.location.z > (camLocation.z+catchLocation.z)-catchWindow.z &&
    s.location.z < (camLocation.z+catchLocation.z)) {
      s.changeState(1);
    } else {
      s.changeState(0); 
    }
    
    s.update();
    s.display();
    if(s.isDead()) {
      stars.remove(i);
    } 
  }
}

//////////////////////
void drawTunnels() {
  
  for(int i = tunnels.size()-1; i >= 0; i--) {
    Tunnel t = tunnels.get(i);
        
    t.update();
    t.display();
    if(t.isDead()) {
      tunnels.remove(i);
    } 
  }
}

//////////////////////
void collectData() {
  //keep previous caught data in their old state
  
  if(millis()-dataTime>datams) {
    // trigger data objects
    int group = floor(random(3));
    
    switch(group) {
      case 0:
        points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(hoog.get(selnum01), breed.get(selnum01), diep.get(selnum01)), materiaal.get(selnum01), true));
        pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex01, 1, "empty"));
        break;
      case 1:
        points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(0, 0, 0), geboorteInfo.get(selnum03), false));
        pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex02, 2, "empty"));
        break;
      case 2:
        points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(0, 0, 0), letterf.get(selnum04), false));
        pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex03, 3, beschrijving.get(seltex03)));
        break;
    }
    
    /* THIS IS THE COLLECTION :)
    points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(hoog.get(selnum01), breed.get(selnum01), diep.get(selnum01)), materiaal.get(selnum01), true));
    points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(0, 0, 0), geboorteInfo.get(selnum03), false));
    points.add(new Point(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), new PVector(0, 0, 0), letterf.get(selnum04), false));

    pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex01, 1, "empty"));
    pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex02, 2, "empty"));
    pointsI.add(new PointImage(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), seltex03, 3, beschrijving.get(seltex03)));
    
    //pointsA.add(new PointAnimation(new PVector(camLocation.x+random(-universeWidth/2, universeWidth/2), camLocation.y+random(-universeHeight/2, universeHeight/2), camLocation.z-universeDepth), textures02[randtex01], title.get(randnum02)));
    */
    
    tunnels.add(new Tunnel(new PVector(camLocation.x, camLocation.y, camLocation.z-universeDepth), 5, new PVector(0, 0, random(12, 16)))); 
    
    // loop through the data, so that when all data has been used
    // we start over at the first data point
    
    selnum01++;
    selnum02++;
    selnum03++;
    selnum04++;
    seltex01++;
    seltex02++;
    seltex03++;
    
    if(selnum01 >= lines01.length) selnum01 = 1;
    if(selnum02 >= lines02.length) selnum02 = 1;
    if(selnum03 >= lines03.length) selnum03 = 1;
    if(selnum04 >= lines05.length) selnum04 = 1;
    if(seltex01 >= numtextures01) seltex01 = 1;
    if(seltex02 >= numtextures02) seltex02 = 1;
    if(seltex03 >= numtextures03) seltex03 = 1;
    
    dataTime = millis();
    datams = random(6000);
  }
  
  
  //IMAGE DATA
  for(int i = pointsI.size()-1; i >= 0; i--) {
    PointImage p = pointsI.get(i);  
    
    if(p.state < 3) {
      float d = dist(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z, p.location.x, p.location.y, p.location.z);
      //camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z
    
      if(p.state < 2) {
        if(p.location.x < (camLocation.x+catchLocation.x)+catchWindow.x && 
        p.location.x > (camLocation.x+catchLocation.x)-catchWindow.x &&
        p.location.y < (camLocation.y+catchLocation.y)+catchWindow.y &&
        p.location.y > (camLocation.y+catchLocation.y)-catchWindow.y &&
        p.location.z > (camLocation.z+catchLocation.z)-catchWindow.z &&
        p.location.z < (camLocation.z+catchLocation.z)) {
          p.changeState(1);
          if(d < catchDist) {
            p.changeState(2);
            caught = true;
          }
        } else {
          p.changeState(0);
        }
      }
      
      p.update();
      p.display();
      
      if(p.isDead()) {
         pointsI.remove(i);
      }
      
    } //end if p.state < 2
    
  } //end for-loop
  
  
  //ANIMATION DATA
  //ok so the for loop is backwards because of some remove actions
  for(int i = pointsA.size()-1; i >= 0; i--) {
    PointAnimation p = pointsA.get(i);  
        
    if(p.state < 3) {
      float d = dist(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z, p.location.x, p.location.y, p.location.z);
      
      if(p.state < 2) {
        if(p.location.x < (camLocation.x+catchLocation.x)+catchWindow.x && 
        p.location.x > (camLocation.x+catchLocation.x)-catchWindow.x &&
        p.location.y < (camLocation.y+catchLocation.y)+catchWindow.y &&
        p.location.y > (camLocation.y+catchLocation.y)-catchWindow.y &&
        p.location.z > (camLocation.z+catchLocation.z)-catchWindow.z &&
        p.location.z < (camLocation.z+catchLocation.z)) {
          p.changeState(1);
          if(d < catchDist) {
            p.changeState(2);
            caught = true;
          }
        } else {
          p.changeState(0);
        }
      }
      
      p.update();
      p.display();
      
      if(p.isDead()) {
         pointsA.remove(i);
      }
      
    } //end if p.state < 2 

  } //end for-loop
  
    
  //DATA
  //ok so the for loop is backwards because of some remove actions
  for(int i = points.size()-1; i >= 0; i--) {
    Point p = points.get(i);  
      
    if(p.state < 3) {
      
      float d = dist(camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z, p.location.x, p.location.y, p.location.z);
      //camLocation.x+catchLocation.x, camLocation.y+catchLocation.y, camLocation.z+catchLocation.z
  
      if(p.state < 2) {
        if(p.location.x < (camLocation.x+catchLocation.x)+catchWindow.x && 
        p.location.x > (camLocation.x+catchLocation.x)-catchWindow.x &&
        p.location.y < (camLocation.y+catchLocation.y)+catchWindow.y &&
        p.location.y > (camLocation.y+catchLocation.y)-catchWindow.y &&
        p.location.z > (camLocation.z+catchLocation.z)-catchWindow.z &&
        p.location.z < (camLocation.z+catchLocation.z)) {
          p.changeState(1);
          if(d < catchDist) {
            p.changeState(2);
            caught = true;
          }
        } else {
          p.changeState(0);
        }
      }
      
      p.update();
      p.display();
      
      if(p.isDead()) {
         points.remove(i);
      }
    } //end if p.state < 2

  } //end for-loop
  
}

//////////////////////
void drawData() {
  //draw data as collection (catch or globe)
 
  //IMAGE DATA
  for(int i = pointsI.size()-1; i >= 0; i--) {
    PointImage p = pointsI.get(i);  
    
    p.update();
    p.display();
    
    if(p.isDead()) {
       pointsI.remove(i);
    }
  }
  //ANIMATION DATA
  for(int i = pointsA.size()-1; i >= 0; i--) {
    PointAnimation p = pointsA.get(i);  
    
    p.update();
    p.display();
    
    if(p.isDead()) {
       pointsA.remove(i);
    }
  }
  //DATA
  for(int i = points.size()-1; i >= 0; i--) {
    Point p = points.get(i);  
    
    p.update();
    p.display();
    
    if(p.isDead()) {
       points.remove(i);
    }
  }
  
  //show personal catch OR show collection globe
  switch(GSTATE) {
    case 0:
  
      pushMatrix();
      translate(camLocation.x, camLocation.y, camLocation.z);
      rotateY(rotateWorld);
      
      scale(400);
      if(!loading) {
        //println(ico.positions.size());
        for (int i=0; i<ico.positions.size(); i++) {
          PVector p = ico.positions.get(i);
          pushMatrix();
          translate(p.x, p.y, p.z);
          scale(0.005);
          shape(bol);
          
    //OPEN CULTURE DATA ORGANIZATIONS
          //hint(DISABLE_DEPTH_TEST);
          //scale(0.3);
          //textAlign(CENTER);
          //textSize(45);
          //if(i == 6) text("Onderwijsmuseum", 0, 0);
          //if(i == 10) text("Open Beelden", 0, 0);
          //if(i == 20) text("TaalUnie", 0, 0);
          //if(i == 60) text("Zeeuws Archief", 0, 0);
          //if(i == 70) text("Erfgoed Gelderland", 0, 0);
          //if(i == 80) text("Rijksdienst voor het Cultureel Erfgoed", 0, 0);
          //hint(ENABLE_DEPTH_TEST);
          
          popMatrix();
          
        }
        
       //WORLD DEBUG!
//        PVector p = ico.positions.get(testPos);
//        pushMatrix();
//        translate(p.x, p.y, p.z);
//        scale(0.05);
//        noStroke();
//        if(blackground) fill(255);
//        else fill(0);
//        box(1);
//        popMatrix();
      }
      
      popMatrix();
      
      
      if(blackground) fill(200);
      else fill(50);
      noStroke();
      textSize(60);
      textAlign(CENTER);
      text("CURRENT PUBLIC CULTURE DATA", width/2, height/2);
      break;
    case 3:
      if(blackground) fill(200);
      else fill(50);
      noStroke();
      textSize(45);
      textAlign(CENTER);
      text("AWESOME, YOU COLLECTED " + caughtCount + " CULTURE DATA POINTS", width/2, 100);
      text("CULTURE DATA WILL GO PUBLIC IN " + (saveLength-(int(millis()-saveTime)))/1000, width/2, 100+40);
      break;
      
  }
      
  
}


void fade(boolean fadeout) {
  
  float transparency;
  
  if(fadeout) {
    transparency = map((fadeLength-(int(millis()-fadeTime))), fadeLength, 0, 0, 255);
  } else {
    transparency = map((fadeLength-(int(millis()-fadeTime))), fadeLength, 0, 255, 0);
  }
  
  if(blackground) fill(0, transparency);
  else fill(255, transparency);
  //the fade interfered with the 3D stuff so disable depth test
  hint(DISABLE_DEPTH_TEST);
  rect(0, 0, width, height);
  hint(ENABLE_DEPTH_TEST);
  
  if(millis()-fadeTime > fadeLength) {
    fadeDone = true;
  }
}



////////////////////////////////////////////////////////////////////
//////////////////////
void changeState(int newState) {
  
  if(GSTATE!=newState) {
    switch(newState) {
      case 0: 
        if(GSTATE==3) {
                    
          //change saved data's state to WORLD
          for(int i = points.size()-1; i >= 0; i--) {
            Point p = points.get(i);
            if(p.state == 3) {
              p.changeState(5);
              p.s_ground = GROUND;
            }
          }
          for(int i = pointsI.size()-1; i >= 0; i--) {
            PointImage p = pointsI.get(i);
            if(p.state == 3) {
              p.changeState(5);
              p.s_ground = GROUND;
            }
          }
          for(int i = pointsA.size()-1; i >= 0; i--) {
            PointAnimation p = pointsA.get(i);
            if(p.state == 3) {
              p.changeState(5);
              p.s_ground = GROUND;
            }
          }
          
          GROUND++;
          println("GAME ROUND: " + GROUND);
          caughtCount = 0;
          leapTimer = millis();
          loadCentage = 0;
          
          saveData();  //overwrite saved data file with new data
        
        }
  
        //reset interaction
        catchLocation.set(0, 0, 0);
        navigation.set(0, 0, 0);
        
        break;
      case 1:
        introTime = millis();
        
        //speed up audio
        //toAudio(1);
        
        Envelope speedControlu = new Envelope(ac, 1);
        player.setRate(speedControlu);
        speedControlu.addSegment(2, 3000); //speed up
        
        break;
      case 2:
        leapTimer = millis();
        gameTime = millis();
        break;
      case 3:
        saveTime = millis();
        //SHOW DATA
        //change new data's state to SHOW or HIDE
        for(int i = points.size()-1; i >= 0; i--) {
          Point p = points.get(i);
          //save points
          if(p.state < 3) {
            if(p.state == 2) p.changeState(3);
            else p.changeState(4);
          }
        }
        for(int i = pointsI.size()-1; i >= 0; i--) {
          PointImage p = pointsI.get(i);
          //save points
          if(p.state < 3) {
            if(p.state == 2) p.changeState(3);
            else p.changeState(4);
          }
        }
        for(int i = pointsA.size()-1; i >= 0; i--) {
          PointAnimation p = pointsA.get(i);
          //save points
          if(p.state < 3) {
            if(p.state == 2) p.changeState(3);
            else p.changeState(4);
          }
        }
        
        //slow down audio
        //toAudio(0);
        
        Envelope speedControld = new Envelope(ac, 2);
        player.setRate(speedControld);
        speedControld.addSegment(1, 3000); //slow back down

        break;
      default:
        break;
    } 
  }
  
  fadeTime = millis();
  goFade = false;
  GSTATE = newState;
}


void keyPressed() {
  if(!loading) {
 
  //button play interaction
  if(keyCode == RIGHT) navigation.x+=1;
  if(keyCode == LEFT) navigation.x-=1;
  if(keyCode == UP) navigation.y-=1;
  if(keyCode == DOWN) navigation.y+=1;
  
  if(key == ' ') {
    if(GSTATE == 3) changeState(0);
    else changeState(GSTATE+1);
  }
  
  if(!export) {
    //KEYPRESSES FOR DEBUGGING
    
    if(key == 'w') peasycam = !peasycam; 
    if(key == 'b') blackground = !blackground; 
    
    if(key == '1') {
      if(GSTATE == 2) tunnels.add(new Tunnel(new PVector(camLocation.x, camLocation.y, camLocation.z-universeDepth), 20, new PVector(0, 0, 30))); 
    }
    
    if(key == '0') {
      //reset Vizer!
      catchLocation.set(0, 0, 0);
    }
      
    if(key == '3') cp5.hide();
    if(key == '4') cp5.show();
    
    if(key == '9') testPos++;
    
    if(key == 'p') saveData(); 
   
    if(key == 'k') saveFrame("data/Screenshots/frame-#####.png");
  }
 
  } //if loading & export is false
  
  if(key == 'm') {
    if(mute) ac.start();
    else ac.stop();
    mute = !mute;
  }
  
}