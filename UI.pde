
int buttonSize = 50;

void setupUI() {
  cp5 = new ControlP5(this);

  // create a toggle
  cp5.addToggle("showData")
     .setPosition(40,height-40-buttonSize)
     .setSize(buttonSize,buttonSize)
     ;
     
  cp5.hide();
  
}