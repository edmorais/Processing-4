/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * SCROLLING FLOWERS (from Genuary 2023! 12/13)
 * by Eduardo Morais 2023 - www.eduardomorais.pt
 */

// libs
// import processing.javafx.*;


// config
int   $appWinWidth   = 1920;
int   $appWinHeight  = 1080;
color $appWinBG      = #000000; // #110D92;
color $appDefStroke  = #FFFFFF;

int   $saveFrameNum  = 0; // 0 to deactivate
int   $saveFrameOffset  = 600; // wait before start recording


// constants
int MAXRAD = 128;
int ROTATIONS = 4;
int MAXSTROKE = 8;
int MAXPETALS = 12;
float MAXSPD = 4;

int FLOWERS = 96;

// globals
Figure[] figures;
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

color fgcolor() { 
  colorMode(HSB, 360, 100, 100);
  return color(random(0, 120), random(50, 100), random(50, 100));
}

color bgcolor() {
  colorMode(HSB, 360, 100, 100);
  return color(random(150, 210), random(50, 100), 16);
}


void setup() {
  $appWinBG = bgcolor();
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(30);

  minRad = MAXRAD / 8;

  figures = new Figure[FLOWERS];
  colorMode(HSB, 360, 100, 100);

  for (int i=0; i<FLOWERS; i++) {
    color c = fgcolor();

    figures[i] = new Figure(
      int(random(width,width*2)), int(random(0,height)), // pos
      minRad, random(minRad,MAXRAD),                     // radius
      int(random(2, random(MAXPETALS/2, MAXPETALS))),   // petals
      random(-PI, PI),                                  // st ang
      random(1, MAXSPD),                                // linear vel
      c, int(random(2, MAXSTROKE))                      // color, stroke
      );
       
  }
}


/*
 DRAW
 */
void draw() {
  for (int i=0; i<figures.length; i++) {
    figures[i].update();
    figures[i].display();
  } 
  
  windowBlur($appWinBG, 64);
  

  if ($saveFrameNum > 0 && 
    frameCount > $saveFrameOffset && frameCount - $saveFrameOffset <= $saveFrameNum)
      saveFrame("frames/#####.tga");
    
}

/* our flower figure */

class Figure {
  PVector position, cen;
  float minrad, maxrad, rad, strot, rot, avel, xvel;
  int strokew, petals;
  color col;
  PGraphics gfx;

  Figure(int x, int y, float mird, float mxrd, int p, float sr, float xv, color c, int sw) {
    position = new PVector(x, y);
    minrad = mird;
    maxrad = mxrd;
    rad = random(minrad, maxrad);
    rot = sr;
    xvel = xv;
    avel = xv/30;
    avel = sr >=0 ? avel : 0-avel;
    petals = p;
    col = c;
    strokew = sw;
    
    gfx = createGraphics(int(maxrad*2+16), int(maxrad*2+16));
    cen = new PVector(gfx.width/2, gfx.height/2); 
  }

  void update() {
    rot+=avel;
    position.x-=xvel;
    if (position.x < 0-maxrad*2) {
      position = new PVector(int(random(width,width*2)), int(random(0,height)));
      avel = 0 - avel;
      col = fgcolor();
      strokew = int(random(2, MAXSTROKE));
      petals = int(random(2, MAXPETALS));
      gfx.clear();
    }

    rad = lerp(minrad, maxrad, abs(sin(rot*petals)));
    
  }

  void display() {
    gfx.beginDraw();
    gfx.blendMode(BLEND);
    gfx.stroke(col, 64);
    gfx.strokeWeight(strokew);
    gfx.noFill();

    PVector angvec = PVector.fromAngle(rot).setMag(rad);
    PVector drawto = PVector.add(cen, angvec);

    gfx.line(cen.x, cen.y,
         drawto.x, drawto.y);
    gfx.endDraw();
    
    blendMode(SCREEN);
    image(gfx, position.x, position.y);
  }
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
