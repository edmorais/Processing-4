/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
  Wind
* by Eduardo Morais 2025 - www.eduardomorais.pt
*/

// libs


// config 
int   WIN_WIDTH      = 1024;
int   WIN_HEIGHT     = 1024;
color WIN_BG         = #221DC2;
color DEFAULT_COLOR  = #FFFFFF;


// constants


// globals
PSystem ps;
PVector speed;
color cor = DEFAULT_COLOR;

/*
  SETTINGS & SETUP
*/
void settings() {
  size(WIN_WIDTH, WIN_HEIGHT);
  pixelDensity(1);
  smooth();
}

void setup() {
  background(WIN_BG);
  noFill();
  noCursor();
  frameRate(75);
  
  PVector emitter = new PVector(width, height);
  PVector speed = new PVector(-2.0, 0.5);
  ps = new PSystem(2000, emitter, speed, cor);
  ps.start();
 
}


/* 
  DRAW
*/
void draw() {
  windowBlur(WIN_BG, 8);
  ps.update();
  ps.display();

}


/* Psys */

class PSystem {
  PVector display; // visible w/h
  PVector speed;
  color cor;
  PVector nm; // noise movement
  Particle[] particles;
  
  PSystem(int pnum, PVector pdisp, PVector pspeed, color pcor) {
    particles = new Particle[pnum];
    display = pdisp.copy();
    speed = pspeed.copy();
    cor = pcor;
    nm = new PVector(0,0);
  }
  
  void start() {
    for (int i = 0; i < particles.length; i++) {
      PVector pos = new PVector(random(0, display.x), random(0, display.y));
      PVector turb = new PVector(noise(pos.x)-0.5, noise(pos.y)-0.5);
      turb.add(speed);
      particles[i] = new Particle(pos, turb, cor);
    }
  }
  
  void update() {
    for (int i = 0; i < particles.length; i++) {
      particles[i].update(nm);
    }
    nm.add(0.1,0.1);
  }
  
  void display() {
    for (int i = 0; i < particles.length; i++) {
      particles[i].display();
    }
  }
  
}


/* Particles */
class Particle {
 PVector pos;
 PVector vel;
 color cor;
 PVector speed;
 
 Particle(PVector ppos, PVector pspeed, color pcor) {
  pos = ppos.copy();
  speed = pspeed.copy();
  vel = pspeed.copy();
  cor = pcor;
 }
 
 void update(PVector nm) {
   PVector turb = new PVector(noise(pos.x+nm.x)-0.5, noise(pos.y+nm.y)-0.5);
   turb.mult(0.1);

   // limits!    
   vel = vel.mag() > speed.mag()*1.5 ? speed.copy() : vel.add(turb);
  
   pos.add(vel);
   
   if (pos.x < 0) {
    pos.x = pos.x + width;
    pos.y = height - pos.y;
   }
   if (pos.x > width) {
    pos.x = pos.x - width;
    pos.y = height - pos.y;
   }
   if (pos.y < 0) {
    pos.y = pos.y + height;
    pos.x = width - pos.x;
   }
   if (pos.y > height) {
    pos.y = pos.y - height;
    pos.x = width - pos.x;
   }
 }
 
 void display() {
   stroke(cor);
   strokeWeight(2);
   point (pos.x, pos.y);
 }
  
}




/* Full window blur */
void windowBlur(color bg, int opacity) {
 noStroke();
 fill(bg, opacity);
 rectMode(CORNER);
 rect(0,0, width, height);
 noFill();
}
