/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * Hockney Delayer - audio controlled
 * by Eduardo Morais 2016 - www.eduardomorais.pt
 
 * You can drag and drop video files into the sketch window
 * Press C to go back to webcam, S to save screenshot
 */

import processing.video.*;
import processing.sound.*;
import drop.*;
import java.util.*;
import java.text.*;

/* options */
int grid_x = 8;
int grid_y = 6;
int border = 8;
int buffer_max = 150;
float mic_level = 1;
int scale_factor = 1;

/* declarations */
PGraphics feed;
Capture cam;
Movie video;
String videoFile;
boolean live = true;
AudioIn input;
Amplitude rms;
PImage[] buffer;
boolean dragged = false;
boolean stopped = false;
SDrop drop; // drag and drop object

int cam_x = 1024;
int cam_y = 768;

int jitter = 10;
int delay = 20;

// allowed video file extensions:
String[] videoExts = {"mov", "avi", "mp4", "mpg", "mpeg"};

PImage fragment = createImage(cam_x/grid_x, cam_y/grid_y, RGB);

int[] offsets_x = new int[grid_x*grid_y];
int[] offsets_y = new int[grid_x*grid_y];
int[] offsets_t = new int[grid_x*grid_y];

/* S E T U P */
void settings() {
  size(scale_factor * (border*(grid_x+1)+cam_x), scale_factor * (border*(grid_y+1)+cam_y));
}
void setup() {
  background(33);

  /* Init offsets & window */

  offsets();
  feed = createGraphics(cam_x, cam_y);

  /* Init cameras */

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");

  } else {
    prepareCamera(cameras[0]);
    buffer = new PImage[buffer_max];
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

/* prepare fragment offsets */
void offsets() {
  for (int i = 0; i < offsets_x.length; i++) {
    int r_x = round(random(0-jitter, jitter));
    int r_y = round(random(0-jitter, jitter));
    int r_t = round(random(0, delay-1));

    if (i < grid_x) {
      r_y = round(random(0, jitter));
    }

    if (i >= grid_x*(grid_y-1)) {
      r_y = round(random(0-jitter, 0));
    }

    if (i % grid_x == 0) {
      r_x = round(random(0, jitter));
    }

    if (i % grid_x == 7) {
      r_x = round(random(0-jitter, 0));
    }

    offsets_x[i] = r_x;
    offsets_y[i] = r_y;
    offsets_t[i] = r_t;
  }
}

/* D R A W - - - - - */
void draw() {
  background(33);
  scale(scale_factor);
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

    // move the framebuffer:
    for (int tx = delay-2; tx >= 0; tx--) {
      if (buffer[tx] != null) {
        buffer[tx+1] = buffer[tx];
      }
    }

    // copy grid fragments:
    for (int gx = 0; gx < grid_x; gx++) {
      for (int gy = 0; gy < grid_y; gy++) {
        int x = border + gx*border + gx*(cam_x/grid_x);
        int y = border + gy*border + gy*(cam_y/grid_y);

        if (buffer[offsets_t[gx*gy]] != null) {
          fragment.copy(buffer[offsets_t[gx*gy]], gx*(cam_x/grid_x) + offsets_x[gx*gy], gy*(cam_y/grid_y) + offsets_y[gx*gy], cam_x/grid_x, cam_y/grid_y, 0, 0, cam_x/grid_x, cam_y/grid_y);
          tint(255, 210-2.0*random(0, jitter));
          image(fragment, x+(random(-jitter, jitter)/5), y+(random(-jitter, jitter)/5), 
                fragment.width+random(0,jitter), fragment.height+random(jitter));
        }
      }
    }
  }

  /* microphone */
  jitter = 0;
  if (rms.analyze() > 0.01) {
    delay = (int) map(rms.analyze(), 0, 1, 0, buffer_max);
    if (rms.analyze() > 0.2) {
      jitter = (int) map(rms.analyze(), 0, 1, 0, 100);
    }
    offsets();
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP && jitter <= 100) {
      jitter += 2;
    }
    if (keyCode == DOWN && jitter >= 2) {
      jitter -= 2;
    }
    if (keyCode == LEFT && delay > 0) {
      delay--;
    }
    if (keyCode == RIGHT && delay < buffer_max) {
      delay++;
    }
    offsets();
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


void keyReleased() {
  if (key == ' ') {
    offsets();
  }

  if (key == 'c' || key == 'C') {
    live = !live;
    // prepareCamera();
  }

  if (key == 's' || key == 'S') {
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_HHmmss");
    save("hockney_" + df.format(now) + ".jpg");
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
