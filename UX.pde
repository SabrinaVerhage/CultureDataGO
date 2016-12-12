
boolean visited = false;

//////////////////////
void checkinteraction() {
  
  if(GSTATE == 0) {
    //loading start rectangle
    if(blackground) fill(255);
    else fill(0);
    hint(DISABLE_DEPTH_TEST);
    rect(0, 0, loadCentage, height);
    hint(ENABLE_DEPTH_TEST);
  }
  
  if(LeapConnected) {
    if(leap.getHands().size() > 0) {
      //println((leapTime - (millis() - leapTimer)));
      loadCentage = map((millis() - leapTimer), 0, leapTime, ploadCentage, width);
      //count down
      if(millis() - leapTimer > leapTime) {
        println("GO");
        if(!loading && GSTATE == 0) changeState(1);
        blackground = !blackground;
      } 
    } else {
      //println("SEARCHING"); 
      leapTimer = millis();
      loadCentage-=10;
      ploadCentage = loadCentage;
      if(loadCentage < 0) loadCentage = 0;
    }
  } else if(MyoConnected) {
    
    
  }
  
  if(!MyoConnected && !LeapConnected) {
    
  }
  
  println("loadcentage: " + loadCentage);
  
  
}

void interaction() {
  
  //add navigation!
  catchLocation.add(navigation);
  
  //prevent vizer from moving out of screen
  if(catchLocation.x > width/2) catchLocation.x = width/2;
  if(catchLocation.y > height/2) catchLocation.y = height/2;
  if(catchLocation.x < -width/2) catchLocation.x = -width/2;
  if(catchLocation.y < -height/2) catchLocation.y = -height/2;
  if(catchLocation.x > width/2 || catchLocation.x < -width/2 || catchLocation.y > height/2 || catchLocation.y < -height/2) {
    navigation.x = 0;
    navigation.y = 0;
  }
  
  if(LeapConnected) {
    
    float handRoll = 0;
    float handPitch = 0;
    
    for (Hand hand : leap.getHands ()) {
      handRoll = hand.getRoll();
      handPitch = hand.getPitch();  
    } 
    
    navigation.x = map(handRoll, 90, -90, 20, -20);
    navigation.y = map(handPitch, -90, 90, 20, -20);
    
    
    if(leap.getHands().size() <= 0) {
      //no hand? finish game
      if(millis() - leapTimer > 8000) {
        changeState(3);
      } 
    } else {
      leapTimer = millis();
    }
    
  } //let's not do Myo & Leap at the same time
  else if(MyoConnected) {
    Myorientation = myo.getOrientation(); //get myo orientation
      
    navigation.x = map(Myorientation.x, 0, 1, 20, -20);
    navigation.y = map(Myorientation.y, 0, 1, 20, -20);
    
  }
  
  
  if(caught) {
    if(MyoConnected) myo.vibrate(1); //fix bug in library!
    blackground=!blackground;
    caught=false;
  }
  
  
  if(blackground) fill(200);
  else fill(50);
  noStroke();
  textSize(35);
  textAlign(LEFT);
  text("TIME: " + (gameLength-(int(millis()-gameTime)))/1000, 20, 60);
  text("CULTURE DATA  COLLECTED: " + caughtCount, 20, 100);
 
}

//doens't work together with the leap motion
/*
void myoOn(Myo.Event event, Device myo, long timestamp) {  
  if(MyoConnected) {
    
    switch(event) {
      case ARM_SYNC:
        if(!loading && GSTATE == 0) changeState(1);
        break;
      case POSE:
        switch (myo.getPose().getType()) {
          case FINGERS_SPREAD:
            //println("GO!");
            if(GSTATE == 2) tunnels.add(new Tunnel(new PVector(camLocation.x, camLocation.y, camLocation.z-universeDepth), 20, new PVector(0, 0, 30))); 

            break;
        }
        break;
      case EMG_DATA:
        Myodata = myo.getEmg();
        setMyodata();
        //println(data); //0-255 (also negative)
        break;
    } 
  
  }//end if MyoConnected
}
*/

void setMyodata() {
  for(int i = 0; i < 8; i++) {
    Myodata[i] = floor(map(Myodata[i], 0, 255, 0, 10000)); 
  }
  
  float lerp = 0.75;

  if(visited) {
    for(int i = 0 ; i < smoothMyodata.length; i++) {
      smoothMyodata[i] = (int)(smoothMyodata[i] * lerp +  Myodata[i] * (1-lerp));
    }
  } else { //first time around we just copy
    for(int i = 0 ; i < smoothMyodata.length; i++) {
      smoothMyodata[i] = Myodata[i];
    }
    visited = true;
  }
  
}