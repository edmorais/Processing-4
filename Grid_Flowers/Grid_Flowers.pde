/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * GRID OF FLOWERS (from Genuary 2023! 08)
 * by Eduardo Morais 2023 - www.eduardomorais.pt
 */

// libs


// config
int   $appWinWidth   = 1920;
int   $appWinHeight  = 1080;
color $appWinBG      = #000000; // #110D92;
color $appDefStroke  = #FFFFFF;

int   $saveFrameNum  = 0; //450; // 0 to deactivate
int   $saveFrameOffset  = 300; // wait before start recording


// constants
int COLS = 16;
int ROWS = 9;
int PADDING = 32;

// globals
Arc[] arcs;
int cellX, cellY, maxRad, minRad;

/*
  SETTINGS & SETUP
 */
void settings() {
  size($appWinWidth, $appWinHeight);
  pixelDensity(1);
}

color fgcolor() { 
  colorMode(HSB, 360, 100, 100);
  return color(random(0, 60), random(50, 100), random(50, 100));
}

color bgcolor() {
  colorMode(HSB, 360, 100, 100);
  return color(random(150, 210), random(50, 100), random(10, 40));
}


void setup() {
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(30);

  cellX = width / COLS;
  cellY = height / ROWS;
  maxRad = cellX > cellY ? (cellY - PADDING) / 2 : (cellX - PADDING) / 2;
  minRad = PADDING / 4;

  arcs = new Arc[ROWS*COLS];
  colorMode(HSB, 360, 100, 100);

  for (int i=0; i<COLS; i++) {
    for (int j=0; j<ROWS; j++) {
      color c = fgcolor();
      color bgc = bgcolor();

      arcs[i*ROWS +j] = new Arc(
        cellX*i + cellX/2, cellY*j +  + cellY/2, // pos
        minRad, maxRad,                          // radius
        random(-1.5, 1.5),                       // grow vel
        random(0, PI), random(-0.2, 0.2),        // st ang, ang vel
        bgc, c, int(random(2, 16))               // color, stroke
        );
    }
  }
}


/*
 DRAW
 */
void draw() {
  for (int i=0; i<arcs.length; i++) {
    arcs[i].update();
    arcs[i].display();
  }

  if ($saveFrameNum > 0 && 
    frameCount >= $saveFrameOffset && frameCount - $saveFrameOffset <= $saveFrameNum)
      saveFrame("frames/#####.tga");
    
}

/* arcs */

class Arc {
  PVector position;
  float minrad, maxrad, rad, gvel, strot, rot, avel;
  int strokew;
  color col, bgcol;

  Arc(int x, int y, float mird, float mxrd, float gv, float sr, float av, color bgc, color c, int sw) {
    position = new PVector(x, y);
    minrad = mird;
    maxrad = mxrd;
    rad = random(minrad, maxrad);
    strot = sr;
    rot = av > 0 ? 0 : TAU;
    avel = av;
    gvel = gv;
    bgcol = bgc;
    col = c;
    strokew = sw;
    this.fillCell();
  }

  void update() {
    rot+=avel;
    if (rot > TAU*2 || rot < -TAU) {
      avel = 0 - avel;
      col = fgcolor();
      bgcol = bgcolor();
      rad = random(10, maxrad);
      strokew = int(random(2, 16));

      this.fillCell();
    }

    rad+=gvel;
    if (rad >= maxrad || rad <= minrad) gvel = 0 - gvel;
  }

  void fillCell() {
    blendMode(BLEND);
    noStroke();
    fill(bgcol, 192);
    rectMode(CENTER);
    rect(position.x, position.y, cellX-PADDING/4, cellY-PADDING/4);
  }

  void display() {
    blendMode(SCREEN);
    stroke(col, 64);
    strokeWeight(strokew);
    noFill();

    PVector angvec = PVector.fromAngle(rot).setMag(rad);
    PVector drawto = PVector.add(position, angvec);

    line(position.x, position.y,
         drawto.x, drawto.y);
  }
}
