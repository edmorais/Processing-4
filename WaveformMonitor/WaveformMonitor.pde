/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * Waveform Monitor
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 * Might grow into its own thing.
 *
 * Drag and drop to play video files.
 * -
 * Keyboard actions:
 * M: Change waveform mode      C: Switch camera / video file
 * B: Dark/Light background     F: Overlay feed (while pressed)
 * W: Toggle warping effect
 */

import processing.video.*;
import drop.*; // third-party library
import java.util.*;
import java.text.*;

/* options */
int cam_x = 640; // video/cam input dimensions
int cam_y = 480;
float cam_mult = 2; // canvas dimension ratio (for HiDPI, etc)
int vert_smooth = 2; // vertical smoothness 

/* & declarations */
PGraphics feed;
Capture cam;
Movie video;
String videoFile;
PGraphics display;
boolean dragged = false;
boolean stopped = false;
SDrop drop; // drag and drop object

// allowed video file extensions:
String[] videoExts = {"mov", "avi", "mp4", "mpg", "mpeg"};

// starting config:
boolean live = true;
boolean warp = false;
boolean show_feed = false;
int bgcolor = 0;

// modes:
final int MODE_LUMA = 0;  // luma
final int MODE_CLUM = 1;  // colorized luma
final int MODE_CLUS = 2;  // colorized luma saturated
final int MODE_RGB  = 3;  // duh!
int mode = MODE_LUMA;     // start in luma mode


/* S E T U P  &etc. - - - - */
void settings() {
  size(round(cam_x*cam_mult), round(cam_y*cam_mult));
}

void setup() {
  background(0);

  /* Init offsets & window */

  feed = createGraphics(cam_x, cam_y);

  /* Init cameras */

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    prepareCamera(cameras[0]);
    display = createGraphics(cam_x, cam_y);
  }

  drop = new SDrop(this);
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

    colorMode(RGB);
    if (mode == MODE_LUMA || mode == MODE_CLUM || mode == MODE_CLUS) colorMode(HSB);

    display.beginDraw();
    display.background(bgcolor);
    display.loadPixels();
    feed.loadPixels();
    for (int i = 0; i < feed.width; i++) {
      float distorted_h = display.height/2-vert_smooth-1;
      float alpha_mult = 1;

      // if warped
      if (warp) {
        float distorted_h_normal = norm(sq(abs(i-(feed.width/2))), 0, sq(feed.width/2));
        // almost half the desired height
        distorted_h = lerp(display.height/2-vert_smooth-4, display.height/8, distorted_h_normal);
        alpha_mult = lerp(1, 0, distorted_h_normal);
      }

      int pos_y;
      float luma_ext, luma, satu, alpha_normal, rc, gc, bc;
      color c;
      for (int j = 0; j < feed.height; j++) {
        c = color(feed.pixels[feed.width*j+i]);
        luma = brightness(c);
        
        // cull clipping values and make blacks and whites more transparent
        if (luma < 1 || luma >=255) continue;
        alpha_normal = alpha_mult * abs(norm(abs(128-luma), 127, 40));

        // Luminance waveform modes
        if (mode != MODE_RGB) { 
          // expand possible luma values and add noise to avoid banding:
          luma_ext = luma * vert_smooth + random(-vert_smooth/2, vert_smooth/2);
          pos_y = int(map(luma_ext, 256*vert_smooth, 0, display.height/2-distorted_h, display.height/2+distorted_h));
          if (mode == MODE_LUMA) display.pixels[display.width*pos_y+i] = color(255-bgcolor, 128*alpha_normal);
          if (mode == MODE_CLUM || mode == MODE_CLUS) {
            luma = luma_ext;
            satu = saturation(c);
            if (mode == MODE_CLUS) satu = 255;
            if (bgcolor > 192 && mode == MODE_CLUM) luma = 255-brightness(c);
            display.pixels[display.width*pos_y+i] = color(hue(c), satu, luma, 128*alpha_normal);
          }
        }

        // RGB waveform mode, superimposing three waveforms:
        if (mode == MODE_RGB) { 
          rc = red(c) * vert_smooth + random(-vert_smooth/2, vert_smooth/2);
          gc = green(c) * vert_smooth + random(-vert_smooth/2, vert_smooth/2);
          bc = blue(c) * vert_smooth + random(-vert_smooth/2, vert_smooth/2);
          pos_y = int(map(rc, 256*vert_smooth, 0, display.height/2-distorted_h, display.height/2+distorted_h/8));
          display.pixels[display.width*pos_y+i] = color(rc, gc/4, 0, 128*alpha_normal);
          pos_y = int(map(gc, 256*vert_smooth, 0, display.height/2-distorted_h/2, display.height/2+distorted_h/2));
          display.pixels[display.width*pos_y+i] = color(rc/6, gc, bc/4, 128*alpha_normal);
          pos_y = int(map(bc, 256*vert_smooth, 0, display.height/2-distorted_h/8, display.height/2+distorted_h));
          display.pixels[display.width*pos_y+i] = color(rc/6, gc/6, bc, 128*alpha_normal);
        }
      }
    }
    feed.updatePixels();
    display.updatePixels();
    display.endDraw();
    image(display, 0, 0, width, height);
  }

  // overlay input feed:
  if (show_feed) {
    blend(feed, 0, 0, feed.width, feed.height, 0, 0, width, height, EXCLUSION);
  }
}


/* U S E R   I N T E R F A C E - - - - - */
void keyReleased() {

  if (key == 'm' || key == 'M') {
    mode++;
    if (mode > MODE_RGB) { 
      mode = MODE_LUMA;
    }
  }

  if (key == 'c' || key == 'C') {
    live = !live;
    colorMode(RGB);
    background(0, 0, 255);
  }

  if (key == 'b' || key == 'B') {
    if (bgcolor == 0) {
      bgcolor = 255;
    } else {
      bgcolor = 0;
    }
  }

  if (key == 'f' || key == 'F') {
    show_feed = false;
  }

  if (key == 'w' || key == 'W') {
    warp = !warp;
  }

  // save image
  if (key == 's' || key == 'S') {
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_HHmmss");
    save("waveform_" + df.format(now) + ".jpg");
  }
}

void keyPressed() {
  if (key == 'f' || key == 'F') {
    show_feed = true;
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
