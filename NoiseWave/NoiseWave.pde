/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * NoiseWave
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 * Press space to toggle horizontal / vertical drawing
 * 
 * After the Perlin noise tutorial at
 * https://necessarydisorder.wordpress.com/2017/11/15/drawing-from-noise-and-then-making-animated-loopy-gifs-from-there/
 */

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

float[] noisey; 
int reso = 3;
int size = 1024;
int size_mult = 1;
Minim minim;
AudioInput in;
boolean horizontal = false;

void settings() {
  size(size*size_mult,size*size_mult);
  smooth();
}
void setup(){
  background(255);
  noFill();
  strokeWeight(size_mult);
  frameRate(60);
  
  /* Init microphone */
  minim = new Minim(this);
  in = minim.getLineIn();
  noisey = new float[in.bufferSize()];
}
 
void draw(){
  background(255);
  float scale = 0.005;

  /* 1D Noise */
  for (int i = 0; i < noisey.length; i += reso*size_mult) {
    // int bpos = int(map(i, 0, in.bufferSize(), 0, width));  // pos
    noisey[i] = height*(noise(scale*i, frameCount*scale)+in.mix.get(i)/4);
  }

  for (int i = 0; i < height/3; i += 10*size_mult) {
    float cn = norm(i, 0, height/3);
    stroke(lerpColor(color(0,0,255),color(255,0,0),cn));
    beginShape();
    if (horizontal) {
      for(int x = 0; x<width;x+=reso*size_mult){
        vertex(x,noisey[x]+i-height/6);
      }  
    } else {
      for(int y = 0; y<width;y+=reso*size_mult){
        vertex(noisey[y]+i-height/6, y);
      }
    }
    endShape();
  }

}

void keyReleased() {
  if (key == ' ') {
    horizontal = !horizontal;
  }
}
