/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
  DEMOSCENE BARS
* by Eduardo Morais 2024 - www.eduardomorais.pt
*/

// libs


// config 
int   WIN_WIDTH      = 1024;
int   WIN_HEIGHT     = 1024;
color WIN_BG         = #221DC2;
color DEFAULT_COLOR  = #FFFFFF;


// constants


// globals
float ph1, ph2, ph3 = 0;
float pht1, pht2, pht3;
int x, y;

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
  windowBlur(WIN_BG, 50);
  //background(WIN_BG);

  pht1 = ph1;
  pht2 = ph2;
  pht3 = ph3;
  
  loadPixels();
  for (y = 0; y < height; y++) {
    x = floor(width/2 + sin(pht1) * (width/6) + sin(pht2) * 36 + sin(pht3) * 28);
  
    for (int i = y; i < width; i++) {
      
      pixels[i*width + x-3] = color(#33006E);
      pixels[i*width + x-2] = color(#663399);
      pixels[i*width + x-1] = WIN_BG;
      pixels[i*width + x] = color(255);
      pixels[i*width + x+1] = color(#FF7733);
      pixels[i*width + x+2] = color(#FF7733);
      pixels[i*width + x+3] = color(#990066);
    }
    // update;
    pht1 += 0.01;
    pht2 += 0.02;
    pht3 += 0.05;
  }
  // update phase;
  ph1 += 0.02;
  ph2 += random(0.02, 0.1);
  ph3 += random(0.05, 0.3);
  updatePixels();
}



/* Full window blur */
void windowBlur(color bg, int opacity) {
 noStroke();
 fill(bg, opacity);
 rectMode(CORNER);
 rect(0,0, width, height);
 noFill();
}
