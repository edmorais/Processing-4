// 3D WEBCAM 1.2
// by Eduardo Morais - remade for processing.video.* May 15th 2022
/*
  "Drag mouse (L button): Rotate view\n"+
  "Drag mouse (R button): Zoom view\n"+
  "Drag mouse (M button): Pan view\n"+
  "Spacebar: Reset view\n"+
  "M: Toggle RGB separation mode\n"+
  "Q: Toggle quality setting\n"+    
  "C: Toggle convexity\n"+    
*/

import peasy.*;
import processing.video.*;

Capture video;
PGraphics buffer;
PeasyCam cam;
CameraState camstate;

int videoWidth = 640;
int videoHeight = 480;
int quality = 2;
int bg = 0;
boolean convex = false;
boolean rgbMode = false;
boolean ok = false;

void setup() {
 size(1024,1024, P3D);
 frameRate(30);
 strokeWeight(2);
 surface.setTitle("Eduardo Morais | 3D Webcam");
 cursor(HAND);  
 
 cam = new PeasyCam(this, 1000);
 cam.setMinimumDistance(600);
 cam.setMaximumDistance(3000);
 cam.lookAt(width/2,height/2,0); 
 cam.rotateY(PI);
 camstate = cam.getState();
 
 buffer = createGraphics(videoWidth, videoHeight);
 String[] cameras = Capture.list();
 printArray(cameras);
 if (cameras.length > 0) {
   video = new Capture(this, cameras[0]);
   video.start();
 } else { exit(); }
}

void draw() {
  background(bg);

  if (video.available()) {
    video.read();
    ok = true;
  }
  image(video, 0, 0, 1,1);
  
  translate(-192,32,0);
  
  if (ok) {
    video.loadPixels();
    float z, cl;
    blendMode(SCREEN);
    noFill();
      
    if (rgbMode) { 

      beginShape();
      for (int y=0; y < video.height; y = y+quality) {
       for (int x=0; x < video.width; x = x+quality) {
        int l = x + y*video.width;
        cl = blue(video.pixels[l]);
        stroke(color(0, 0, cl, cl));
        if (x==0) noStroke();
        z = convex? cl - 128 : 128 - cl;
        vertex(x*2,y*2,z+128);
       }
      }
      endShape();


      beginShape();
      for (int y=0; y < video.height; y = y+quality) {
       for (int x=0; x < video.width; x = x+quality) {
        int l = x + y*video.width;
        cl = green(video.pixels[l]);
        stroke(color(0, cl, 0,cl));
        if (x==0) noStroke();
        z = convex? cl - 128 : 128 - cl;
        vertex(x*2,y*2,z);
       }
      }
      endShape();

      beginShape();
      for (int y=0; y < video.height; y = y+quality) {
       for (int x=0; x < video.width; x = x+quality) {
        int l = x + y*video.width;
        cl = red(video.pixels[l]);
        stroke(color(cl,0,0,cl));
        if (x==0) noStroke();
        z = convex? cl - 128 : 128 - cl;
        vertex(x*2,y*2,z-128);
       }
      }
      endShape();

    } else {
      
      // LUMA
      beginShape();
      for (int y=0; y < video.height; y = y+quality) {
       for (int x=0; x < video.width; x = x+quality) {
        int l = x + y*video.width;
        cl = brightness(video.pixels[l]);
        stroke(cl);
        if (x==0) noStroke(); 
        z = convex? cl - 128 : 128 - cl;
        vertex(x*2,y*2,z);
       }
      }
      endShape();
    }
  }


}

void mouseDragged() {
  noCursor(); 
}

void mouseReleased() {
  cursor(HAND); 
}

void keyPressed() {
   if (key == 'q' || key == 'Q') {
     quality = quality+1;
     if (quality==5) { quality=1;  }
   }
   if (key == 'c' || key == 'C') {
     convex = !convex; 
   }

   if (key == 'm' || key == 'M') {
     if (rgbMode) { rgbMode = false;  } else { rgbMode = true; }
   }
}

void keyReleased() {
  if (key == ' ') {
    cam.setState(camstate,2500);
    cam.lookAt(width/2,height/2,0);   
  }
}
  
public void stop(){
  video.stop();//stop the object
  super.stop();
}
