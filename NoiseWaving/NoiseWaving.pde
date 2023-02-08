/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * NoiseWaving
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 */

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

float[] noisey; 
int reso = 2;
int size = 1024;
int size_mult = 1;
float cn = 0;
float cd = 0.005;
Minim minim;
AudioInput in;
PGraphics gbA, gbB;
boolean bw = false;

void settings() {
  size(size*size_mult,size*size_mult);
}
void setup(){
  background(255);
  frameRate(60);
  noFill();
  noCursor();

  gbA = createGraphics(width, height*2);
  gbB = createGraphics(width, height*2);

  gbA.beginDraw();
  gbA.noFill();
  gbA.strokeWeight(size_mult);
  gbA.background(255);
  gbA.endDraw();

  gbB.beginDraw();
  gbB.noFill();
  gbB.strokeWeight(size_mult);
  gbB.background(255);
  gbB.endDraw();
  
  /* Init microphone */
  minim = new Minim(this);
  in = minim.getLineIn();
  noisey = new float[in.bufferSize()];

  //noLoop();
}
 
void draw() {
  float scale = 0.005;

  /* 1D Noise */
  for (int i = 0; i < noisey.length; i += reso*size_mult) {
    noisey[i] = (noise(scale*i, frameCount*scale) + in.mix.get(i)/4);
  }

  // color normal:
  cn += cd;
  if (cn <= 0 || cn >= 1) cd = 0-cd;

  if (bw) {
    gbA.stroke(lerpColor(color(255,0),color(64,255),cn));
    gbB.stroke(lerpColor(color(255,0),color(64,255),cn));  
  } else {
    gbA.stroke(lerpColor(color(255,50,0,0),color(0,100,255,255),cn));
    gbB.stroke(lerpColor(color(255,0,120,0),color(0,120,200,255),cn));  
  }
  

  gbA.beginDraw();
  gbA.beginShape();
  gbB.beginDraw();
  gbB.beginShape();
  for (int i = 0; i < noisey.length; i += reso*size_mult) {
    float x = map(i, 0, noisey.length, 0, width);
    gbA.vertex(x,noisey[i]*height+height/4);
    gbB.vertex(x,noisey[i]*height+height/4-reso*size_mult);
  } 
  gbA.endShape();
  gbA.endDraw();
  gbB.endShape();
  gbB.endDraw();

  gbA.beginDraw();
  gbA.image(gbA, 0, reso*size_mult);
  gbA.endDraw();

  gbB.beginDraw();
  gbB.image(gbB, 0, -reso*size_mult);
  gbB.endDraw();

  tint(255,192);
  image(gbB, 0, -height/4);
  tint(255,128);
  image(gbA, 0, -height/4-reso*size_mult);

  beginShape();
  stroke(lerpColor(color(255,50,0,32),color(128,0),cn));
  strokeWeight(2*size_mult);
  for (int i = 0; i < noisey.length; i += reso*size_mult) {
    float x = map(i, 0, noisey.length, 0, width);
    vertex(x,noisey[i]*height-reso*size_mult);
  } 
  endShape();

}

void keyPressed() {
  if (key == 'C' || key == 'c') {
    bw = !bw;
  }
  if (key == ' ') {
    loop();
  }
}
