/*
 * Playhead
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 * Dot class
 */

class Dot {
  
  float x, y, d, freq, vel;
  color cor;
  boolean playing;
  
  // construct
  Dot(float px, float py, float pvel, color pc, float pd, float pfreq) {
    x = px;
    y = py;
    vel = pvel;
    d = pd;
    cor = pc;
    freq = pfreq;
    playing = false;
  }
  
  void update() {
    update(1);
  } 
  void update(float pvm) {
    x = x + vel*pvm;
    if (mousePressed && ismouseover()) {
      x = x - vel*pvm;
      d = d + random(-5,5);
      if (d < 20) d = 20;
      if (d > 80) d = 80;
    }
    if (x > width) x = -d;
  }
  
  int display() {
    int r = 0;
    noStroke();
    fill(cor);
    // play
    if (x > plhead - d/2 && x < plhead + d/2) {
       noFill();
       stroke(cor);
       strokeWeight(3);
       if (playing == false) {
          oscil.play(freq, 0.6);
//        oscil2.play(freq*2, 0.3);          
          env.play(oscil, 0.001, 0.005, 0.3, 0.8);
        //env.play(oscil2, 0.001, 0.005, 0.3, 1.2);
          playing = true;
       }
    } else {
      playing = false;
    }
    if (ismouseover()) {
      cor = color(random(0,150),random(50,150),random(100, 255));
      fill(255,0,0,16);
      r = 1;
    }
    ellipseMode(CENTER);
    ellipse(x, y, d, d);
    return r;
  }
  
  boolean ismouseover() {
    boolean r = false;
    if (dist(mouseX, mouseY, x, y) < d/2) r = true;
    return r;
  }
  
}
