/* //<>//
  Bounce (entropy) 
  Eduardo Morais - reworked 2022
*/

import peasy.*;

PVector loc;
PVector vel;
PVector rot;
PVector rotvel;
color BGn = #221DC2; //IKB
color BGp = #92221D;
color BG = BGn;
float entropy = 1; // 1 or -1
float accel = 0.05;

PeasyCam cam;
CameraState camstate;

void setup() {
  size(1024, 1024, P3D);
  background(BG);
  smooth();
  
   cam = new PeasyCam(this, 1000);
   cam.setMinimumDistance(600);
   cam.setMaximumDistance(3000);
   cam.lookAt(width/2,height/2,height/2); 
   cam.rotateY(PI);
   camstate = cam.getState();

  initCoords();
}

void initCoords() {
  loc = new PVector(random(32,width-32), random(32,height-32), random(32,height-32)); //<>//
  vel = new PVector(random(-4,4), random(-4,4), random(-4,4));
  rot = new PVector(random(0,PI),random(0,PI),random(0,PI));
  rotvel = new PVector(random(-0.02,0.02),random(-0.02,0.02),random(-0.02,0.02));
}

void draw() {
  rot.add(rotvel);
  loc.add(vel);
  if ((loc.x > width-width/24) || (loc.x < width/24)) {
    vel.x = vel.x * -abs(entropy-accel);
    rotvel.x = -rotvel.x;
    println("X=", loc.x);
  }
  if ((loc.y > height-width/24) || (loc.y < width/24)) {
    vel.y = vel.y * -abs(entropy-accel);
    rotvel.y = -rotvel.y;
    println("Y=", loc.y);
  }
  if ((loc.z > height-width/24) || (loc.z < width/24)) {
    vel.z = vel.z * -abs(entropy-accel);
    rotvel.z = -rotvel.z;
    println("Z=", loc.z);
  }
  
  if (vel.x>width/2||vel.y>height/2||vel.z>height/2) initCoords();
  
 translate(width/2,height/2,height/2);
 fill(BG, 64);
 stroke(255, 64);
 
 hint(DISABLE_DEPTH_TEST); // 3D surface opacity thing 
 box(width,height,height);
 pushMatrix(); 
 translate(loc.x-width/2,loc.y-height/2,loc.z-height/2);
 rotateX(rot.x);
 rotateY(rot.y);
 rotateZ(rot.z);
 stroke(255, 128);
 sphereDetail(9);
 noFill();
 sphere(width/24);
 popMatrix();
  
}

void keyReleased() {
  if (key == ' ') {
    entropy = -entropy;
    BG = entropy > 0 ? BGp : BGn;
    
    println("Entropy switch");
    
  }
  if (key == 'r') initCoords();
}
