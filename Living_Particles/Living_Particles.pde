/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
  Living Particles
* by Eduardo Morais 2023 - www.eduardomorais.pt
* based on https://hackmd.io/MSMue_iBTk2vtv7XYgy70Q
*/

// libs


// config 
int   $appWinWidth   = 1024;
int   $appWinHeight  = 1024;
color $appWinBG      = #120D82;
color $appDefStroke  = #FFFFFF;


// constants
int   NUM = 2048;
int   SPECIES_NUM = 8;
int   PAD = 16;
int   SIMDETAIL = 2; // more is less

// globals
float  $ruleAmp = 4; // rule amplitude
float  $thickness = 2;
int    $tick;

PVector[] $speciesRules;
Critter[] $critters;


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
  noStroke();
  noCursor();
  frameRate(60);
  colorMode(HSB);
  
  $critters = new Critter[NUM];
  for (int i=0; i<NUM; i++) $critters[i] = new Critter();
  
  $speciesRules = new PVector[SPECIES_NUM];
  for (int i=0; i<SPECIES_NUM; i++) {
     $speciesRules[i] = new PVector(
         random(-$ruleAmp,$ruleAmp), random(-$ruleAmp,$ruleAmp)
     );
     print($speciesRules[i]);
  }
}


/* 
  DRAW
*/
void draw() {
  windowBlur($appWinBG, 16);
  //background($appWinBG);
  blendMode(SCREEN);
  
  $tick = $tick == SIMDETAIL ? 0 : $tick+1;
  
  PVector force;
  float forceMag;

  for (int i=0; i<NUM; i++) {
      $critters[i].update();
      $critters[i].display();
                  
      for (int j=$tick; j<NUM; j+=SIMDETAIL) {
          force = PVector.sub($critters[i].pos, $critters[j].pos);
          forceMag = force.magSq();
          
          if (forceMag < pow(width/10, 2)) {
             float mag = map(forceMag, pow(width/10, 2), 0, 0, 1.0/width*SIMDETAIL );
             
             if (forceMag < pow(width/256, 2)) {
                 mag = map(forceMag, pow(width/256, 2), 0, 0, 1.0*SIMDETAIL );
                 force.setMag(mag);
             } else {
                 force.setMag(mag * 
                      ($speciesRules[$critters[i].species].x - 
                      $speciesRules[$critters[j].species].y));
             }
             $critters[i].vel.add(force);
          }
      }     
  }
  
}

class Critter {
    PVector pos, vel;
    int species;
    
    Critter() {
        pos = new PVector(random(width), random(height));
        vel = new PVector(random(-1,1),random(-1,1));
        species = int(random(SPECIES_NUM));
    }
    
    void update() {
        pos.add(vel);
        vel.mult(.985);
        
        if (pos.x > width+PAD) pos.x = -PAD;
        if (pos.x < -PAD) pos.x = width+PAD;
        if (pos.y > height+PAD) pos.y = -PAD;
        if (pos.y < -PAD) pos.y = height+PAD;
    }
    
    void display() {
        fill(color(species*(192/SPECIES_NUM), 255, 128));
        ellipse(pos.x, pos.y, $thickness, $thickness);
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
