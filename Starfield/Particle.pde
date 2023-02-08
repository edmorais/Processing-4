/*
 * Particle class
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 */

class Particle {

  PVector pos;
  PVector vel;
  color[] colors;
  color cor;
  float weight;
  float speed;
  float turbulence = 0;
  int life;
  int opacity;

  // construct particle
  // by default the velocity equals the starting position vector, then normalized * speed
  Particle(PVector ppos, float pspeed, float pturbo, int plife) {
      pos = ppos.copy();
      vel = ppos.copy();
      speed = pspeed;
      vel.normalize().mult(random(0, speed));
      life = plife;

      // actual turbulence is dependent on speed
      if (pturbo > 0) turbulence = vel.mag()*pturbo;
      
      // defaults
      colors = new color[1];
      colors[0] = color(255);
      weight = 1;  
  }

  // set the particle velocity vector (normalized * speed)
  void setVelocity(PVector pvel) {
      vel = pvel.copy();
      vel.normalize().mult(random(0, speed));
  }

  // set the particle color according to its speed
  void setColors(color[] pcolors) {
      colors = new color[pcolors.length];
      arrayCopy(pcolors, colors);

      // find the particle speed percentile
      float a = map(vel.mag(), 0, speed, 0, 1);
      // multiply it by the number of colors and get the indexes for the colors before and after
      float ac = a * (colors.length-1);
      int c1 = floor(ac);
      int c2 = ceil(ac);

      // get the precise color
      cor = lerpColor(colors[c1], colors[c2], ac-floor(ac));

      // set a starting opacity
      opacity = (int) random (0, 128);
  }

  // set the particle weight
  void setWeight(float pweight) {
      weight = random(0.5, pweight);
  }

  // update the particle
  void update() {
      life--;

      // opacity depends on life
      if (opacity < 255) opacity++;
      if (life < 255) opacity = life;
      
      // add velocity to position vector
      if (turbulence > 0) {
        pos.add(vel).add(random(-turbulence,turbulence),random(-turbulence,turbulence));
      } else {
        pos.add(vel);
      }
  } 
  
  // display particle
  void display() {
      // mess with opacity
      float a = alpha(cor) * opacity/255;
      stroke(cor, a);
      strokeWeight(weight);
      point(pos.x, pos.y);  
  }

  
}
