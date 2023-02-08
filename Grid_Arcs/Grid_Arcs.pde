/*
   ____   __                 __       __  ___              _
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * GRID OF ARCS (from Genuary 2023! 07)
 * by Eduardo Morais 2023 - www.eduardomorais.pt
 */

// libs


// config
int   $appWinWidth   = 1920;
int   $appWinHeight  = 1080;
color $appWinBG      = #000000; // #110D92;
color $appDefStroke  = #FFFFFF;

int   $saveFrameNum  = 600; //450; // 0 to deactivate
int   $saveFrameOffset  = 150; // wait before start recording


// constants
int COLS = 16;
int ROWS = 9;
int PADDING = 32;

// globals
Arc[] arcs;
int cellX, cellY, maxDia, minDia;

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
  return color(random(150, 210), random(50, 100), random(20, 50));
}


void setup() {
  background($appWinBG);
  noFill();
  noCursor();
  frameRate(30);

  cellX = width / COLS;
  cellY = height / ROWS;
  maxDia = cellX > cellY ? cellY - PADDING : cellX - PADDING;
  minDia = PADDING / 2;

  arcs = new Arc[ROWS*COLS];
  colorMode(HSB, 360, 100, 100);

  for (int i=0; i<COLS; i++) {
    for (int j=0; j<ROWS; j++) {
      color c = fgcolor();
      color bgc = bgcolor();

      arcs[i*ROWS +j] = new Arc(
        cellX*i + cellX/2, cellY*j +  + cellY/2, // pos
        minDia, maxDia, // dia
        random(-1.5, 1.5), // grow vel
        random(0, PI), random(-0.2, 0.2), // st ang, ang vel
        bgc, c, int(random(2, 16))                     // color, stroke
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


  if ($saveFrameNum > $saveFrameOffset && $saveFrameNum >= frameCount) saveFrame("frames/#####.tga");
}

/* arcs */

class Arc {
  PVector position;
  float mindia, maxdia, dia, gvel, strot, rot, avel;
  int strokew;
  color col, bgcol;

  Arc(int x, int y, float mid, float mxd, float gv, float sr, float av, color bgc, color c, int sw) {
    position = new PVector(x, y);
    mindia = mid;
    maxdia = mxd;
    dia = random(mindia, maxdia);
    strot = sr;
    rot = av > 0 ? 0 : TAU;
    avel = av;
    gvel = gv;
    bgcol = bgc;
    col = c;
    strokew = sw;
  }

  void update() {
    rot+=avel;
    if (rot > TAU || rot < 0) {
      avel = 0 - avel;
      col = fgcolor();
      bgcol = bgcolor();
      dia = random(10, maxDia);
      strokew = int(random(2, 16));
    }

    dia+=gvel;
    if (dia >= maxdia || dia <= mindia) gvel = 0 - gvel;
  }

  void display() {
    blendMode(BLEND);
    noStroke();
    fill(bgcol, 12);
    rectMode(CENTER);
    rect(position.x, position.y, cellX-PADDING/4, cellY-PADDING/4);

    stroke(col);
    strokeWeight(strokew);
    noFill();
    arc(position.x, position.y,
      dia, dia,
      strot+rot, strot+rot*2);
  }
}
