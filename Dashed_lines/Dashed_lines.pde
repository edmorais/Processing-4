/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
  Dashed line tests
* by Eduardo Morais 2023 - www.eduardomorais.pt
*/

// config 
int   $appWinWidth   = 1024;
int   $appWinHeight  = 1024;
color $appWinBG      = #221DC2;
color $appDefStroke  = #FFFFFF;


/*
  SETTINGS & SETUP
*/
void settings() {
  size($appWinWidth, $appWinHeight);
  pixelDensity(1);
}

void setup() {
  background($appWinBG);
  noFill();
  stroke($appDefStroke);
  strokeWeight(2);
  noCursor();
  frameRate(60);
  
  rectMode(CENTER);
  drect(15, 10, width/2, height/2, width/1.5, height/2);
  dline(15, 10, width/4, height/4, width*3/4, height*3/4);
  dpolygon(15, 10, width/2, height/2, height/6, 8);
}


/* dashed polygon */
void dpolygon(float dash, float gap, float x, float y, float radius, int npoints) {
  float angle = TAU / npoints;
  float sx = x + cos(0) * radius;
  float sy = y + sin(0) * radius;
  float ex, ey;
  
  for (float a = angle; a < TAU; a += angle) {
    ex = x + cos(a) * radius;
    ey = y + sin(a) * radius;
    dline(dash, gap, sx, sy, ex, ey);
    sx = ex;
    sy = ey;
  }
  
}

/* dashed rect - accepts rectMode CENTER or else CORNER */
void drect(float dash, float gap, float x, float y, float w, float h) {
  if (getGraphics().rectMode == CENTER) translate(-w/2, -h/2);
  
  dline(dash, gap, x, y, x+w, y);
  dline(dash, gap, x+w, y, x+w, y+h);
  dline(dash, gap, x+w, y+h, x, y+h);
  dline(dash, gap, x, y+h, x, y);
  
  if (getGraphics().rectMode == CENTER) translate(w/2, h/2);
}


/* Dashed line */
void dline(float dash, float gap, float x1, float y1, float x2, float y2) {
  PVector p1 = new PVector(x1,y1);
  PVector p2 = new PVector(x2,y2);
  float ang = PVector.sub(p2,p1).heading();
  float len = PVector.sub(p2,p1).mag();
  
  PVector dashv = PVector.fromAngle(ang).setMag(dash);
  PVector gapv = PVector.fromAngle(ang).setMag(gap);
  
  while (len > 0) {
    p2 = PVector.add(p1, dashv);
    line(p1.x,p1.y, p2.x,p2.y);
    p1 = PVector.add(p2, gapv);
    
    len = len - (dash+gap);
    if (len < dashv.mag()) dashv = PVector.fromAngle(ang).setMag(len);
  }  
}
