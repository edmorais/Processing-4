/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 < BLANK 3D SKETCH - TITLE >
 * by Eduardo Morais 2022 - www.eduardomorais.pt
 */

// libs
import peasy.*;

// config
int   $appWinWidth   = 1024;
int   $appWinHeight  = 1024;
color $appWinBG      = #221DC2;
color $appDefStroke  = #FFFFFF;
color $appDefFill  = #FFFFFF;

// constants


// globals
PeasyCam $cam;
CameraState $camstate;


/*
  SETTINGS & SETUP
 */
void settings() {
  size($appWinWidth, $appWinHeight, P3D);
  pixelDensity(1);
}

void setup() {
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(60);

  // PeasyCam
  $cam = new PeasyCam(this, width);
  $cam.setMinimumDistance(width/4);
  $cam.setMaximumDistance(width*4);
  $cam.lookAt(width/2, height/2, 0);
  $cam.rotateX(-PI/3);
  $camstate = $cam.getState();
}


/*
 DRAW
 */
void draw() {
  windowBlur($appWinBG, 0);
  rectMode(CENTER);
  fill($appDefFill);
  stroke($appDefStroke);
  hint(DISABLE_DEPTH_TEST); // 3D surface opacity thing
  rect(width/2, height/2, width/4, height/4);
}



/* Full window blur */
void windowBlur(color bg, int opacity) {
  if (opacity==0) {
    background(bg);
    return;
  }

  noStroke();
  fill(bg, opacity);
  rectMode(CORNER);
  rect(0, 0, width, height);
  noFill();
}
