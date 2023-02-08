/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 Perlin Landscape
 * by Eduardo Morais 2022 - www.eduardomorais.pt
 */

// libs
import peasy.*;

// app config
int   $appWinWidth   = 1024;
int   $appWinHeight  = 1024;
color $appWinBG      = #000000;
color $appDefStroke  = #00FF00;
color $appDefFill  = #000000;

// globals
int $noise_detail = 4;
float $noise_incr = 0.02;
float $noise_yco = 0;
float $speed = 0.02; 

PeasyCam $cam;
CameraState $camstate;
PImage $frame;


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
  
  $frame = createImage(width/2, height/2, ARGB);

  // PeasyCam
  $cam = new PeasyCam(this, width*2);
  $cam.setMinimumDistance(width/6);
  $cam.setMaximumDistance(width*4);
  $cam.lookAt(0, 0, 0);
  $cam.rotateX(-PI/3);
  $camstate = $cam.getState();
}


/*
 DRAW
 */
void draw() {
  windowBlur($appWinBG, 0);
  stroke($appDefStroke,128);

  
  
  // draw texture
  float xco = 0;
  noiseDetail($noise_detail);
  
  // line size
  float xls = width*4 / $frame.width;
  float yls = height*4 / $frame.height;
  
  
  $frame.loadPixels();
  for (int x = 0; x < $frame.width; x++) {
    xco += $noise_incr;
    float xv = map(x, 0, $frame.width, -width*2,width*2);
    
    beginShape();  
    float yco = $noise_yco;

    for (int y = 0; y < $frame.height; y++) {
      yco += $noise_incr;
      float yv = map(y, 0, $frame.height, -height,height*3);
      
      float luma = noise(xco,yco) * 255;
      
      vertex(xv, yv, luma*3);
      //vertex(xv, yv+yls, luma*3);
      vertex(xv+xls, yv+yls, luma*3);
      //vertex(xv+xls, yv, luma*3);
      
        
      // clouds?
      $frame.pixels[x+y*$frame.width] = color(luma, luma);      
    }
    endShape();
  }
  $frame.updatePixels();
  $noise_yco -= $speed;
  
  // place clouds
  imageMode(CENTER);
  translate(0,0,height);
  image($frame, 0, 0, width*4, height*4);
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
