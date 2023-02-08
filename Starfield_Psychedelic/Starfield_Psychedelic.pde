/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * STARFIELD ODYSSEY (MORE PSYCHEDELIC) (from Genuary 2023! 30)
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
int MAXRAD = 128, SPREAD = 8;
int MAXSTROKE = 8;
int MAXPETALS = 12,  MAXSIDES = 16;
float MAXSPD = 4, MAXSCALE = 5, MOUSEF = 8, JITTER = 0.25, ROTSPD = 0.01;
int FLOWER_NUM = 48, POLY_NUM = 24, STAR_NUM = 8, POINT_NUM = 600;
// internal
int SHAPE_POLYGON = 0;
int SHAPE_FLOWER = 1;
int SHAPE_STAR = 2;
int SHAPE_POINT = 3;


// globals
Shape[] flowers;
Shape[] polys;
Shape[] stars;
Shape[] points;
int maxRad, minRad;
float mx, my, $rot = 0;
PGraphics $fr;


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

PVector startpos(int spread) {
  return new PVector(int(random(-width/spread,width/spread)), int(random(-height/spread,height/spread)));
}

void setup() {
  colorMode(HSB, 360, 100, 100);
  $appWinBG =  color(random(180, 210), random(70, 100), 8);
  
  $fr = createGraphics(width,height);
  background($appWinBG);
  
  noFill();
  //noCursor();
  frameRate(30);

  flowers = new Shape[FLOWER_NUM];
  polys = new Shape[POLY_NUM];
  stars = new Shape[STAR_NUM];
  points = new Shape[POINT_NUM];

  colorMode(HSB, 360, 100, 100);
  for (int i=0; i<FLOWER_NUM; i++) {
    flowers[i] = new Shape(
      SHAPE_FLOWER,
      MAXRAD / 10, random(MAXRAD / 8,MAXRAD),               // radius
      int(random(2, random(MAXPETALS/2, MAXPETALS))),       // petals
      random(-PI, PI),                                      // st ang
      fgcolor(-30, 60), int(random(2, MAXSTROKE))             // color, stroke
      );
  }

  for (int i=0; i<STAR_NUM; i++) {
    stars[i] = new Shape(
      SHAPE_STAR,
      MAXRAD / 16, random(MAXRAD / 16,MAXRAD/4),               // radius
      int(random(2, random(MAXPETALS/2, MAXPETALS))),       // POINTS
      random(-PI, PI),                                      // st ang
      fgcolor(300, 360), int(random(2, MAXSTROKE))             // color, stroke
      );
  }

  for (int i=0; i<POLY_NUM; i++) {
    polys[i] = new Shape(
      SHAPE_POLYGON,
      MAXRAD / 8, random(MAXRAD / 8,MAXRAD),                // radius
      int(random(3, random(MAXSIDES/2, MAXSIDES))),         // sides
      random(-PI, PI),                                      // st ang
      fgcolor(210, 270), int(random(2, MAXSTROKE))          // color, stroke
      );
  }
  
  for (int i=0; i<POINT_NUM; i++) {
    points[i] = new Shape(
      SHAPE_POINT, 
      MAXRAD / 8, random(MAXRAD / 4,MAXRAD),               // radius
      int(random(3, random(MAXSIDES/2, MAXSIDES))),         // sides
      random(-PI, PI),                                      // st ang
      fgcolor(180, 210), 1                                    // color, stroke
      );
  }

}


/*
 DRAW
 */
void draw() {
  background(0);
  $fr.beginDraw();
  windowBlur($fr, $appWinBG, 16);
  
  // mx = (pmouseX + mouseX)/2;
  // my = (pmouseY + mouseY)/2;
  mx = $fr.width/2;
  my = $fr.height/2;
  $rot+=ROTSPD;
 
  $fr.blendMode(SCREEN);
  for (int i=0; i<points.length; i++) {
    points[i].draw($fr, mx,my,64);
  } 
  
  $fr.blendMode(SCREEN);
  for (int i=0; i<polys.length; i++) {
    polys[i].draw($fr, mx,my,8);
  } 

  $fr.blendMode(ADD);
  for (int i=0; i<flowers.length; i++) {
   flowers[i].draw($fr, mx,my,8);
  } 

  $fr.blendMode(SCREEN);
  for (int i=0; i<stars.length; i++) {
    stars[i].draw($fr, mx,my,16);
  } 
 


  $fr.endDraw();
  image($fr,0,0);
  scale(1,-1);
  blendMode(SCREEN);
  image($fr,0,-height);

  if ($saveFrameNum > 0 && 
    frameCount > $saveFrameOffset && frameCount - $saveFrameOffset <= $saveFrameNum) {
      saveFrame("frames/#####.tga");
      print("|"); 
    }
    
}

/* polygons */

class Shape {
  PVector position;
  float minrad, maxrad, rad, rot, avel, sc, svel;
  int shape, strokew, sides;
  color col;

  Shape(int s, float mird, float mxrd, int p, float sr, color c, int sw) {
    position = startpos(SPREAD);
    minrad = mird;
    maxrad = mxrd;
    rad = random(minrad, maxrad);
    rot = sr;
    sc = 0;
    svel = map(rad, 0, MAXRAD, 0, MAXSPD*2);
    avel = sr >=0 ?  svel/(MAXSPD*10) : 0 - svel/(MAXSPD*10);
    sides = p;
    col = c;
    strokew = sw;
    shape = s;
  }

  void draw(PGraphics fr, float ox, float oy, int opacity) {
    rot+=avel/10;
    position.x+=random(-JITTER, JITTER);
    position.y+=random(-JITTER, JITTER);
    sc+=svel/100;

    if (sc > MAXSCALE/2) opacity = int(map(sc, MAXSCALE/2, MAXSCALE, opacity, 0));
    if (sc < MAXSCALE/6) opacity = int(map(sc, MAXSCALE/6, 0, opacity, 0));    
    
    if (sc > MAXSCALE) {
      sc = 0;
      position = startpos(SPREAD);
      avel = 0 - avel;
      sides = int(random(2, MAXSIDES));
      return;
    }

    fr.stroke(col, opacity);
    fr.strokeWeight(strokew);
    fr.noFill();
    
    ox = fr.width/2 + (ox-fr.width/2)/MOUSEF;
    oy = fr.height/2 + (ox-fr.height/2)/MOUSEF;
    fr.translate(ox, oy);
    fr.rotate($rot);

    fr.pushMatrix();
    fr.scale(sc);
    fr.translate(position.x, position.y);
    fr.rotate(rot);
    
    if (shape == SHAPE_FLOWER) flower(fr, 0,0, minrad, maxrad, sides, 8*sc);
    else if (shape == SHAPE_STAR) star(fr, 0,0, minrad, maxrad, sides);
    else if (shape == SHAPE_POINT) fr.point(0,0);
    else polygon(fr, 0,0, rad, sides);
    
    fr.popMatrix();
    fr.rotate(-$rot);
    fr.translate(-ox, -oy);
    
  }
}

/* draw flower */

void flower(PGraphics fr, float x, float y, float minrad, float maxrad, int npetals, float detail) {
  if (detail < npetals*4) detail = npetals * 4;
  float ac = TAU / detail;

  for (float angle = 0; angle < TAU; angle+=ac) {
    float radius = lerp(minrad, maxrad, abs(sin(angle*npetals)));
    PVector drawto = PVector.add(new PVector(x,y), 
    PVector.fromAngle(angle).setMag(radius));
                         
    fr.line(x, y, drawto.x, drawto.y);
  }
}

/* draw star */

void star(PGraphics fr, float x, float y, float minrad, float maxrad, int npoints) {
  float angle = TAU / npoints / 2;
  fr.beginShape();
  for (float a = 0; a < TAU; a += angle) {
    float sx = x + cos(a) * maxrad;
    float sy = y + sin(a) * maxrad;
    fr.vertex(sx, sy);
    a+= angle;
    sx = x + cos(a) * minrad;
    sy = y + sin(a) * minrad;
    fr.vertex(sx, sy);
  }
  fr.endShape(CLOSE);
}

/* from the Regular Polygon example */

void polygon(PGraphics fr, float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  fr.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    fr.vertex(sx, sy);
  }
  fr.endShape(CLOSE);
}


/* Full window blur */
void windowBlur(PGraphics fr, color bg, int opacity) {
   fr.blendMode(BLEND);
   fr.noStroke();
   fr.fill(bg, opacity);
   fr.rectMode(CORNER);
   fr.rect(0,0, fr.width, fr.height);
   fr.noFill();
}
