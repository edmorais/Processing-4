/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * SCROLLING SHAPES (from Genuary 2023! 25)
 * by Eduardo Morais 2023 - www.eduardomorais.pt
 */

// config
int   $appWinWidth   = 1920;
int   $appWinHeight  = 1080;
color $appWinBG      = #110D92;
color $appDefStroke  = #FFFFFF;

int   $saveFrameNum  = 0; // 0 to deactivate
int   $saveFrameOffset  = 0; // wait before start recording


// constants
int MAXRAD = 128;
int MAXSTROKE = 8;
int MAXPETALS = 12,  MAXSIDES = 12;
float MAXSPD = 3.5;
int FLOWER_NUM = 72, POLY_NUM = 160;

// globals
Flower[] flowers;
Poly[] polys;
int cellX, cellY, maxRad, minRad;


/*
  SETTINGS & SETUP
 */
void settings() {
  // brute MS Surface display density fix:   
  size($appWinWidth / displayDensity(), $appWinHeight / displayDensity());
  MAXRAD/=displayDensity();
  MAXSTROKE/=displayDensity();
}

color fgcolor(int hs, int he) { 
  colorMode(HSB, 360, 100, 100);
  return color(random(hs, he), random(50, 100), random(50, 100));
}

void setup() {
  colorMode(HSB, 360, 100, 100);
  $appWinBG =  color(random(180, 210), random(70, 100), 16);
  
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(30);

  flowers = new Flower[FLOWER_NUM];
  polys = new Poly[POLY_NUM];

  colorMode(HSB, 360, 100, 100);
  for (int i=0; i<FLOWER_NUM; i++) {
    flowers[i] = new Flower(
      int(random(width,width*2)), int(random(0,height)),    // pos
      MAXRAD / 10, random(MAXRAD / 8,MAXRAD),                // radius
      int(random(2, random(MAXPETALS/2, MAXPETALS))),       // petals
      random(-PI, PI),                                      // st ang
      fgcolor(0, 60), int(random(2, MAXSTROKE))            // color, stroke
      );
  }

  for (int i=0; i<POLY_NUM; i++) {
    polys[i] = new Poly(
      int(random(width,width*2)), int(random(0,height)),    // pos
      MAXRAD / 8, random(MAXRAD / 8,MAXRAD),                        // radius
      int(random(3, random(MAXSIDES/2, MAXSIDES))),         // sides
      random(-PI, PI),                                      // st ang
      fgcolor(210, 270), int(random(2, MAXSTROKE))          // color, stroke
      );
  }

}


/*
 DRAW
 */
void draw() {
  windowBlur($appWinBG, 24);

  blendMode(SCREEN);
  for (int i=0; i<polys.length; i++) {
    polys[i].draw(24);
  } 

  blendMode(SCREEN);
  for (int i=0; i<flowers.length; i++) {
    flowers[i].draw(12);
  } 

  if ($saveFrameNum > 0 && 
    frameCount > $saveFrameOffset && frameCount - $saveFrameOffset <= $saveFrameNum)
      saveFrame("frames/#####.tga");
    
}

/* polygons */

class Poly {
  PVector position;
  float minrad, maxrad, rad, rot, avel, xvel;
  int strokew, sides;
  color col;

  Poly(int x, int y, float mird, float mxrd, int p, float sr, color c, int sw) {
    position = new PVector(x, y);
    minrad = mird;
    maxrad = mxrd;
    rad = random(minrad, maxrad);
    rot = sr;
    xvel = map(rad, 0, MAXRAD, 1, MAXSPD);
    avel = sr >=0 ?  xvel/(MAXSPD*10) : 0 - xvel/(MAXSPD*10);
    sides = p;
    col = c;
    strokew = sw;
  }

  void draw(int opacity) {
    rot+=avel/10;
    position.x-=xvel;
    
    if (position.x < 0-maxrad*2) {
      position = new PVector(int(random(width,width*2)), int(random(0,height)));
      avel = 0 - avel;
      strokew = int(random(2, MAXSTROKE));
      sides = int(random(2, MAXSIDES));
      return;
    }

    stroke(col, opacity);
    strokeWeight(strokew);
    noFill();

    pushMatrix();
    translate(position.x, position.y);
    rotate(rot);
    
    polygon(0,0, rad, sides);
    
    popMatrix();

  }
}


/* our flower figure */

class Flower {
  PVector position;
  float minrad, maxrad, rot, avel, xvel;
  int strokew, petals;
  color col;

  Flower(int x, int y, float mird, float mxrd, int p, float sr, color c, int sw) {
    position = new PVector(x, y);
    minrad = mird;
    maxrad = mxrd;
    rot = sr;
    xvel = map(maxrad, 0, MAXRAD, 1, MAXSPD);
    avel = sr >=0 ? xvel/(MAXSPD*10) : 0-xvel/(MAXSPD*10);
    petals = p;
    col = c;
    strokew = sw;
  }

  void draw(int opacity) {
    rot+=avel/10;
    position.x-=xvel;
    
    if (position.x < 0-maxrad*2) {
      position = new PVector(int(random(width,width*2)), int(random(0,height)));
      avel = 0 - avel;
      strokew = int(random(2, MAXSTROKE));
      petals = int(random(2, MAXPETALS));

      return;
    }

    stroke(col, opacity);
    strokeWeight(strokew);
    noFill();

    pushMatrix();
    translate(position.x, position.y);
    rotate(rot);
    
    flower(0,0, minrad, maxrad, petals, 60);
 
    popMatrix();

  }
}

/* draw flower */

void flower(float x, float y, float minrad, float maxrad, int npetals, int detail) {
  if (detail < npetals*4) detail = npetals * 4;
  float ac = TAU / detail;

  for (float angle = 0; angle < TAU; angle+=ac) {
    float radius = lerp(minrad, maxrad, abs(sin(angle*npetals)));
    PVector drawto = PVector.add(new PVector(x,y), 
                                 PVector.fromAngle(angle).setMag(radius));
    line(x, y, drawto.x, drawto.y);
  }
}


/* from the Regular Polygon example */

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}


/* Full window blur */
void windowBlur(color bg, int opacity) {
   blendMode(BLEND);
   noStroke();
   fill(bg, opacity);
   rectMode(CORNER);
   rect(0,0, width, height);
   noFill();
}
