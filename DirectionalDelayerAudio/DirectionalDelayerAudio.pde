/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * Directional Delayer - audio controlled
 * by Eduardo Morais 2016-2025 - www.eduardomorais.pt
 
 * You can drag and drop video files into the sketch window
 * Press C to go back to webcam, S to save screenshot
 * Press 1 to 5 to select mode (but big audio peaks can change the mode!)
 */

import processing.video.*;
import processing.sound.*;
import drop.*; // third-party library 
import java.util.*;
import java.text.*;

/* options */
int cam_x = 1280; // video/cam input dimensions
int cam_y = 720;
float cam_mult = 1; // canvas dimension ratio
float mic_level = 1;
boolean dithering = false; // dithering
float dither = 0;


/* & declarations */
PGraphics feed;
Capture cam;
Movie video;
String videoFile;
boolean live = true;
AudioIn input;
Amplitude rms;
PImage[] buffer;
PGraphics display;
int buffer_max = 150;
int delay = 20;
boolean dragged = false;
boolean stopped = false;
SDrop drop; // drag and drop object

float[] offsets = new float[cam_x*cam_y];

// allowed video file extensions:
String[] videoExts = {"mov", "avi", "mp4", "mpg", "mpeg"};

// modes:
final int RAND = 0;
final int GRADIENT_LR = 1;
final int GRADIENT_RL = 2;
final int GRADIENT_TB = 3;
final int GRADIENT_BT = 4;
int mode = RAND;

boolean showMap = false; // show delay map

/* S E T U P  &etc. - - - - */
void settings() {
  size(round(cam_x*cam_mult), round(cam_y*cam_mult));
  smooth();
}
void setup() {
  background(0);

  /* Init offsets & window */

  offsets();
  feed = createGraphics(cam_x, cam_y);

  /* Init cameras */

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    prepareCamera(cameras[0]);
    buffer = new PImage[buffer_max];
    display = createGraphics(cam_x, cam_y);
  }

  /* Init microphone */
  input = new AudioIn(this, 0);
  input.start();
  input.amp(mic_level);
  // create a new Amplitude analyzer
  rms = new Amplitude(this);
  // Patch the input to an volume analyzer
  rms.input(input);

  drop = new SDrop(this);
}

/*
Prepare pixel offsets
 */
void offsets() {
  if (delay < 0) {
    delay = 0;
  }
  if (delay >= buffer_max) {
    delay = buffer_max - 1;
  }
  dither = 0;
  
  if (mode == RAND) {
    for (int i = 0; i < offsets.length; i++) {
      float r = random(0, delay);
      offsets[i] = r;
    }
  }
  // horizontal gradient
  if (mode == GRADIENT_LR || mode == GRADIENT_RL) {
    if (dithering) dither = ceil(width/cam_x)*2;
    for (int x = 0; x < cam_x; x++) {
      float o = 0;
      float so = 0;
      if (mode == GRADIENT_LR) {
        o = map(x, 0, cam_x, 0, delay);
      } else if (mode == GRADIENT_RL) {
        o = map(x, cam_x, 0, 0, delay);
      }
      for (int y = 0; y < cam_y; y++) {
        so = o;
        if (dithering) {
          so += random(-dither,dither);
          so = constrain(so, 0, delay);
        }
        offsets[y*cam_x+x] = so;
      }
    }
  }
  // vertical gradient
  if (mode == GRADIENT_TB || mode == GRADIENT_BT) {
    if (dithering) dither = ceil(height/cam_y)*2;
    for (int y = 0; y < cam_y; y++) {
      float o = 0;
      float so = 0;
      if (mode == GRADIENT_TB) {
        o = map(y, 0, cam_y, 0, delay);
      } else if (mode == GRADIENT_BT) {
        o = map(y, cam_y, 0, 0, delay);
      }
      for (int x = 0; x < cam_x; x++) {
        so = o;
        if (dithering) {
          so += random(-dither,dither);
          so = constrain(so, 0, delay);
        }
        offsets[y*cam_x+x] = so;
      }
    }
  }
}

/* D R A W - - - - - */
void draw() {
  boolean ok = false;
  feed.beginDraw();
  if (live && cam != null && cam.available()) {
    cam.read();
    feed.image(cam, 0, 0, feed.width, feed.height);
    ok = true;
  } else if (video != null && video.available()) {
    video.read();
    feed.image(video, 0, 0, feed.width, feed.height);
    ok = true;
  }
  feed.endDraw();

  /* camera */
  if (ok) {

    buffer[0] = feed.get();
    buffer[0].loadPixels();

    for (int tx = delay-2; tx >= 0; tx--) {
      if (buffer[tx] != null) {
        buffer[tx+1] = buffer[tx];
        buffer[tx+1].loadPixels();
      }
    }

    display.beginDraw();
    display.loadPixels();
    for (int i = 0; i < offsets.length; i++) {
      if (showMap) {
        display.pixels[i] = color(map(offsets[i], 0, buffer_max, 0, 255));
      } else
        if (buffer[floor(offsets[i])] != null) {
          color cf = buffer[floor(offsets[i])].pixels[i];
          if (buffer[ceil(offsets[i])] != null) {
            float r = offsets[i] - floor(offsets[i]);
            color cc = buffer[ceil(offsets[i])].pixels[i];
            cf = lerpColor(cf, cc, r);
          }
          display.pixels[i] = cf;
        }
    }
    display.updatePixels();
    display.endDraw();
    image(display, 0, 0, width, height);
  }

  /* microphone */
  if (rms.analyze() > 0.01) {
    delay = (int) map(rms.analyze(), 0, 1, 0, buffer_max);
    offsets();
  }
  if (rms.analyze() > 0.5) {
    mode = (int) random(1, 5);
    offsets();
  }
}

void keyPressed() {
  if (key == 'm' || key == 'M') {
    showMap = true;
  }
}

void keyReleased() {

  if (key == 'c' || key == 'C') {
    live = !live;
    // prepareCamera();
  }

  if (key >= '1' && key <= '5') {
    if (mode != key - '1') {
      mode = key - '1';
      offsets();
      background(0);
    }
  }

  if (key == 'm' || key == 'M') {
    showMap = false;
  }

  if (key == 'd' || key == 'D') {
    dithering = !dithering;
    offsets();
  }

  if (key == 's' || key == 'S') {
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_HHmmss");
    save("delayer_" + df.format(now) + ".jpg");
  }
}



/*
 * Select video file
 */
void selectVideo(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    videoFile = null;
  } else {
    println("User selected " + selection.getAbsolutePath());
    String fn = selection.getName();
    String fext = fn.substring(fn.lastIndexOf(".") + 1, fn.length());
    String ext;
    boolean ok = false;

    for (int i = 0; i < videoExts.length; i++) {
      ext = videoExts[i];
      if (ext.equalsIgnoreCase(fext)) {
        ok = true;
        break;
      }
    }

    if (ok) {
      videoFile = selection.getAbsolutePath();
      boolean s = stopped;
      stopped = true;
      prepareVideo();
      stopped = s;
    } else if (!dragged) {
      selectInput("Please select a supported video file...", "selectVideo");
    }
  }
  dragged = false;
}

void prepareCamera(String cs) {
  cam = new Capture(this, cs);
  cam.start();
  live = true;
  if (video != null) {
    video.stop();
  }
}


/*
 * PREPARE VIDEO FILE
 */
void prepareVideo() {
  if (videoFile != null) {
    if (video != null) {
      video.stop();
    }
    video = new Movie(this, videoFile);
    video.jump(0);
    video.loop();
    video.play();
    video.volume(0);
    video.read();
    live = false;
  }
}


/*
 * Drag & drop
 */
void dropEvent(DropEvent dropped) {
  if (dropped.isFile()) {
    dragged = true;
    selectVideo(dropped.file());
  }
}
