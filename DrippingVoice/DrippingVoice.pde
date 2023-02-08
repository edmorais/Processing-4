/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * Dripping Voice
 * by Eduardo Morais 2015 - www.eduardomorais.pt
 */

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioInput in;
int t = 0;
int cel = 300;
float s;
int cm = 0;
color cor;
int ctrans = 64;

void setup() {
   size(1024,1024);
   background(255);
   minim = new Minim(this);
   in = minim.getLineIn();
   cm = floor(random(0,4));
   s = random(100, width-100);
   frameRate(60);
   smooth();
}

void draw() {

  for (int i = 0; i < in.bufferSize(); i++) {
     float y = map(i, 0, in.bufferSize(), t-cel, t);  // pos
     float c = map(abs(in.mix.get(i)), 0, 1, 100, 255); // color

     float trans = map(i, 0, in.bufferSize(), 0, ctrans);

     if (cm == 0) cor = color(c, c/4, 0, trans);
     if (cm == 1) cor = color(0, c/4, c, trans);
     if (cm == 2) cor = color(c/4, 0, c, trans);
     if (cm == 3) cor = color(c, 0, c/4, trans);

     float amp = sq(in.mix.get(i))*500;
     stroke(cor);
     line(s - amp, y, s + amp, y);

     s += random(-0.05,0.05);
  }
  
  t += random(-2,7);

  if(t > height + 50) {
    t = 0;
    s = random(100, width-100);
    cm = floor(random(0,4));
  }
}

void keyReleased() {
  if (key == 'r' || key == 'R') { 
    background(255);
    t = 0;
  }
}
