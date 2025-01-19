/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
  < BLANK SKETCH - TITLE >
* by Eduardo Morais 2022 - www.eduardomorais.pt
*/

// libs


// config 
int   WIN_WIDTH      = 1024;
int   WIN_HEIGHT     = 1024;
color WIN_BG         = #221DC2;
color DEFAULT_COLOR  = #FFFFFF;


// constants


// globals


/*
  SETTINGS & SETUP
*/
void settings() {
  size(WIN_WIDTH, WIN_HEIGHT);
  pixelDensity(1);
}

void setup() {
  background(WIN_BG);
  noFill();
  noCursor();
  frameRate(60);
}


/* 
  DRAW
*/
void draw() {
  // windowBlur(WIN_BG, 10);
  /*
  stroke(DEFAULT_COLOR);
  line(random(0,width),random(0,height), 
       random(0,width),random(0,height));
  */

  
}



/* Full window blur */
void windowBlur(color bg, int opacity) {
 noStroke();
 fill(bg, opacity);
 rectMode(CORNER);
 rect(0,0, width, height);
 noFill();
}
