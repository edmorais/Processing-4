/*
 * Bitfield
 * by Eduardo Morais 2021 - www.eduardomorais.pt
 *
 * Experimenting with bitfield formulas found on the web
 */

int mode = 1;

boolean save = false;

int window_x = 1024;
int window_y = 1024;
int scaling = 2;

int factor_min = 2;
int factor_max = 100;
int speed = 10;
int factor = int(random(factor_min, factor_max));

PGraphics buffer;

void settings () {
  size(window_x,window_y);
}

void setup() {
  background(0);
  buffer = createGraphics(window_x/scaling, window_y/scaling);
}

void draw () {
  int ff = int(random(factor-speed, factor+speed));
  while (ff < factor_min || ff > factor_max) {
    ff = int(random(factor-speed, factor+speed));
  }
  factor = ff;
  
  buffer.beginDraw();
  buffer.background(#221DC2);
  buffer.loadPixels();
  for (int x=0; x < buffer.width; x++) {
    for (int y=0; y < buffer.height; y++) {
      boolean hit = false;
      if (mode==0) {
        if ((x ^ y) % factor == 0) { hit=true; }
      }
      if (mode==1) {
        if ((x | y) % factor == 0) { hit=true; }
      }
      if (mode==2) {
        if (((x * y) & factor) == 0) {hit=true; }
      }
      
      if (hit) {
        int pos = buffer.width*y + x;
        buffer.pixels[pos] = color(255);
      }
    }
  }
  buffer.updatePixels();
  buffer.endDraw();
  image(buffer, 0,0, window_x,window_y);

  if (save) saveFrame("bitfield-######.png");
}

void keyReleased() {
  if (key >= '1' && key <= '3') {
    if (mode != key - '1') {
      mode = key - '1';
    }
  }
  if (key == 's' || key == 'S') {
    saveFrame("bitfield-######.png");
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT && factor_max > factor_min+5) {
      factor_max--;
    }
    if (keyCode == RIGHT && factor_max < 500) {
      factor_max++;
    }
    println("F ",factor_max);
  }
}
