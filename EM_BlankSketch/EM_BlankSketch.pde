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
int   $appWinWidth   = 1024;
int   $appWinHeight  = 1024;
color $appWinBG      = #221DC2;
color $appDefStroke  = #FFFFFF;


// constants


// globals


/*
  SETTINGS & SETUP
*/
void settings() {
  size($appWinWidth, $appWinHeight);
  pixelDensity(1);
}

void setup() {
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(60);
}


/* 
  DRAW
*/
void draw() {
  // windowBlur($appWinBG, 10);
  stroke($appDefStroke);
  line(random(0,width),random(0,height), 
       random(0,width),random(0,height));
}



/* Full window blur */
void windowBlur(color bg, int opacity) {
 noStroke();
 fill(bg, opacity);
 rectMode(CORNER);
 rect(0,0, width, height);
 noFill();
}
