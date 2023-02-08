/*
 * PSystem class
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 */

class PSystem {
  
  float emitter_width, emitter_height;
  float speed, turbulence, weight;
  PVector velocity;
  int life_min, life_max;
  color[] colors;

  Particle[] particles;

  
  // construct
  PSystem(int pnum, 
          float pemitter_w, float pemitter_h, float pspeed, float pturbo, 
          int plife_min, int plife_max) {
      particles = new Particle[pnum];
      
      emitter_width = pemitter_w;
      emitter_height = pemitter_h;
      speed = pspeed;
      turbulence = pturbo;
      velocity = new PVector(0,0);
      weight = 1;
      life_min = plife_min;
      life_max = plife_max;
      colors = new color[1];
      colors[0] = color(255);
  }

  // start the particle system
  // overload with 0,0 velocity vector if necessary 
  // (the particle object will have a velocity equal to the starting position, normalized*speed)
  void start() {
      start(new PVector(0,0));
  }
  void start(PVector pvel) {
      velocity = pvel.copy();
      for (int i = 0; i < particles.length; i ++) {
        create(i);
      }
  }

  // create particle  
  void create(int id) {
      // random position within the emitter area
      PVector pos = new PVector(random(-emitter_width/2,emitter_width/2),random(-emitter_height/2,emitter_height/2));
      
      int life = (int) random(life_min, life_max);

      // create particle object & set attributes
      // Particle(PVector ppos, float pspeed, float pturbo, int plife)
      particles[id] = new Particle(pos, speed, turbulence, life);
      particles[id].setColors(colors);
      particles[id].setWeight(weight);

      // if velocity is not 0,0 (that is, automatic), then set it according to the universal velocity
      if (velocity.x != 0 || velocity.y != 0) particles[id].setVelocity(velocity);
  }

  // set colors for new particles
  void setColors(color[] pcolors) {
      colors = new color[pcolors.length];
      arrayCopy(pcolors, colors);  
  }

  // set weight for new particles
  void setWeight(float pweight) {
      weight = pweight;
  }

  // set speed for new particles
  void setSpeed(float pspeed) {
      speed = pspeed;
  }

  // set turbulence for new particles
  void setTurbo(float pturbo) {
      turbulence = pturbo;
  }

  // set new velocity vector for all particles
  void setVelocity(PVector pvel) {
    for (int i = 0; i < particles.length; i ++) {
      particles[i].setVelocity(pvel);
    }  
  }

  // update all particles
  void update() {
    for (int i = 0; i < particles.length; i ++) {
      particles[i].update();
      if (particles[i].life <= 0) create(i);
    }
  } 
  
  // display all particles
  void display() {
    for (int i = 0; i < particles.length; i ++) {
      particles[i].display();
    }  
  }
  
}
