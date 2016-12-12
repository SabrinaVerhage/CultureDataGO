
void loadData() {
  loading = true;
  
  //LOAD IMAGE DATA
  for(int i = 0; i < textures01.length; i++) {
    textures01[i] = loadImage("Image/01/01 (" + (i+1) + ").jpg");
    textures01[i].resize(200, 0);
    dtextures01[i] = imageToDisplacementMap(textures01[i]);
    displace01[i] = loadShader("displaceFrag.glsl", "displaceVert.glsl");
  }
  
  for(int i = 0; i < textures02.length; i++) {
    textures02[i] = loadImage("Image/02/02 (" + (i+1) + ").jpg");
    textures02[i].resize(200, 0);
    dtextures02[i] = imageToDisplacementMap(textures02[i]);
    displace02[i] = loadShader("displaceFrag.glsl", "displaceVert.glsl");
  }
  
  for(int i = 0; i < textures03.length; i++) {
    textures03[i] = loadImage("Image/03/03 (" + (i+1) + ").jpg");
    textures03[i].resize(200, 0);
    dtextures03[i] = imageToDisplacementMap(textures03[i]);
    displace03[i] = loadShader("displaceFrag.glsl", "displaceVert.glsl");
  }
  
  //LOAD STRING DATA
  //////SCHOOLTASSEN
  lines01 = loadStrings("Data/schooltassen.csv");
  
  for(int i = 0; i < lines01.length; i++) {
    hoog.add(0f);
    breed.add(0f);
    diep.add(0f);
    materiaal.add("test");
  }
  
  for(int i = 0; i < lines01.length; i++) {
    String[] pieces = split(lines01[i], ';');
    if (pieces.length == 8) {
      
      materiaal.set(i, "SCHOOLTAS: " + pieces[3]);
      
      //SORT THAT SHIT
      for(int j = 4; j < 7; j++) {
        for(int k = 4; k < 7; k++) {
          if(float(pieces[j]) > float(pieces[k+1])) {
             float tempVar = float(pieces[k+1]);
             pieces[k+1] = pieces[j];
             pieces[j] = str(tempVar);
          }
        }
      }

      hoog.set(i, float(pieces[4]) * 15);
      breed.set(i, float(pieces[5]) * 15);
      diep.set(i, float(pieces[6]) * 15);
          
    } 
  }
  
  //////OPEN BEELDEN
  lines02 = loadStrings("Data/openbeelden.csv");

  for(int i = 0; i < lines02.length; i++) {    
    title.add("test");
  }

  for(int i = 0; i < lines02.length; i++) {
    String[] pieces = split(lines02[i], ';');
    if (pieces.length == 22) {
      title.set(i, pieces[1]);
    } 
  }
  
  //////ZEEUWSARCHIEF
  lines03 = loadStrings("Data/zeeuwsarchief.csv");
  
  for(int i = 0; i < lines03.length; i++) {
    geboorteInfo.add("test"); 
  }
  
  for(int i = 0; i < lines03.length; i++) {
    String[] pieces = split(lines03[i], ';');
    if(pieces.length == 8) {
       geboorteInfo.set(i, pieces[2] + " " + pieces[3] + " " + pieces[4] + " " + pieces[5] + " " + pieces[6]);
    }
  }
  
  //////MONUMENTEN
  lines04 = loadStrings("Data/monumenten.csv");
  
  for(int i = 0; i < lines04.length; i++) {
    beschrijving.add("test"); 
  }
  
  for(int i = 0; i < lines04.length; i++) {
    String[] pieces = split(lines04[i], ';');
    if(pieces.length == 7) {
       beschrijving.set(i, pieces[5]);
    }
  }
  
  //////LETTERF
  lines05 = loadStrings("Data/letterf.csv");
  
  for(int i = 0; i < lines05.length; i++) {
    letterf.add("test"); 
  }
  
  for(int i = 0; i < lines05.length; i++) {

     letterf.set(i, lines05[i]);
  }
  
  selnum01 = 1;
  selnum02 = 1;
  selnum03 = 1;
  selnum04 = 1;
  
  
  //SAVED DATA
  File f1 = new File(dataPath(curDate + "01.csv"));
  File f2 = new File(dataPath(curDate + "02.csv"));

  if(f1.exists() || f2.exists()) {
    println("saved data found, loading...");

    savedLines01 = loadStrings(f1); 

    for(int i = 0; i < savedLines01.length; i++) {
      String[] pieces = split(savedLines01[i], ';');
      if(pieces.length == 6) {
          PVector s = new PVector();
          PVector sr = new PVector();
          PVector cd = new PVector();
        for(int j = 0; j < 6; j++) {
          if(j == 0 || j == 1 || j == 4) {
            String[] values = split(pieces[j], ',');
            if(values.length == 3) {
              if(j == 0) s.set(float(values[0]), float(values[1]), float(values[2]));
              if(j == 1) sr.set(float(values[0]), float(values[1]), float(values[2]));
              if(j == 4) cd.set(float(values[0]), float(values[1]), float(values[2]));
            }
          }
        }
        
        if(int(pieces[5]) > GROUND) GROUND = int(pieces[5]);

        //println("these are found vectors: " + s + sr + cd);
        //println("this is the boolean: " + boolean((int(pieces[3]))) + pieces[3]);
        points.add(new Point(s, sr, pieces[2], boolean((int(pieces[3]))), cd, int(pieces[5])));
      }
    }
    savedLines02 = loadStrings(f2); 

    for(int i = 0; i < savedLines02.length; i++) {
      String[] pieces = split(savedLines02[i], ';');
      if(pieces.length == 6) {
          PVector sr = new PVector();
          PVector cd = new PVector();
        for(int j = 0; j < 6; j++) {
          if(j == 3 || j == 4) {
            String[] values = split(pieces[j], ',');
            if(values.length == 3) {
              if(j == 3) sr.set(float(values[0]), float(values[1]), float(values[2]));
              if(j == 4) cd.set(float(values[0]), float(values[1]), float(values[2]));
            }
          }
        }
        
        if(int(pieces[5]) > GROUND) GROUND = int(pieces[5]);
        
        pointsI.add(new PointImage(int(pieces[0]), int(pieces[1]), pieces[2], sr, cd, int(pieces[5])));
      }
    }
    
    println("we start from: " + GROUND);
    
  } else {
    println("no saved data found, starting fresh..."); 
  }

  loading = false;
}

void saveData() {
  if(!saving) {
    saving = true;
    
    //points: size, srotation, text, draw, catchDelta, s_ground;
    //pointsI: 
    
    String[] lines_points = new String[points.size()];
    for(int i = 0; i < points.size(); i++) {
      lines_points[i] = points.get(i).size.x + "," + points.get(i).size.y + "," + points.get(i).size.z
      + ";" + points.get(i).srotation.x + "," + points.get(i).srotation.y + "," + points.get(i).srotation.z
      + ";" + points.get(i).text + ";" + int(points.get(i).draw) 
      + ";" + points.get(i).catchDelta.x + "," + points.get(i).catchDelta.y + "," + points.get(i).catchDelta.z
      + ";" + points.get(i).s_ground;  
            
      //println(points.get(i).size.x + "," + points.get(i).size.y + "," + points.get(i).size.z
      //+ ";" + points.get(i).srotation.x + "," + points.get(i).srotation.y + "," + points.get(i).srotation.z
      //+ ";" + points.get(i).text + ";" + int(points.get(i).draw) 
      //+ ";" + points.get(i).catchDelta.x + "," + points.get(i).catchDelta.y + "," + points.get(i).catchDelta.z
      //+ ";" + points.get(i).s_ground);
    }
    saveStrings("data/" + curDate + "01.csv", lines_points);
    
    String[] lines_pointsI = new String[pointsI.size()];
    for(int i = 0; i < pointsI.size(); i++) {
      lines_pointsI[i] = pointsI.get(i).num + ";" + pointsI.get(i).dataset 
      + ";" + pointsI.get(i).text 
      + ";" + pointsI.get(i).srotation.x + "," + pointsI.get(i).srotation.y + "," + pointsI.get(i).srotation.z
      + ";" + pointsI.get(i).catchDelta.x + "," + pointsI.get(i).catchDelta.y + "," + pointsI.get(i).catchDelta.z
      + ";" + pointsI.get(i).s_ground;  
            
      //print
      //println(pointsI.get(i).num + ";" + pointsI.get(i).dataset 
      //+ ";" + pointsI.get(i).text 
      //+ ";" + pointsI.get(i).srotation.x + "," + pointsI.get(i).srotation.y + "," + pointsI.get(i).srotation.z
      //+ ";" + pointsI.get(i).catchDelta.x + "," + pointsI.get(i).catchDelta.y + "," + pointsI.get(i).catchDelta.z
      //+ ";" + pointsI.get(i).s_ground);
    }
    saveStrings("data/" + curDate + "02.csv", lines_pointsI);
        
    saving = false;
  }
}