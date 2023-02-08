/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
   Particle Starfield
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 * Drag mouse to recenter. LEFT/RIGHT: Rotate
 * -
 * More keyboard actions:
 * UP/DOWN: Particle speed 		W/shift-W: Particle size		
 * T/shift-T: Turbulence 		C: Randomize colours
 * P: Toggle pause/resume
 *
 * M: Experimental mode toggle (snowfall)
 *
 * Backslash/shift-backslash: Reset (hard)
 */


// config:
int 	NUM_PARTICLES 	= 8000;

/* snowfall */
/*
PVector EMMITER 		= new PVector(1280, 72);
PVector ORIGIN 			= new PVector(640, 0);
boolean CENTER_ORIGIN 	= false;
PVector	VELOCITY 		= new PVector(0, 2); // 0, 0 : away from CENTER
float 	ROTATION 		= 0;
*/

/* starfield */
PVector EMMITER 		= new PVector(128, 72);
PVector ORIGIN 			= new PVector(0, 0);
boolean CENTER_ORIGIN 	= true;
PVector	VELOCITY 		= new PVector(0, 0); // 0, 0 : away from CENTER
float 	ROTATION 		= 0.1;

float 	SPEED_MAX 		= 3;
float 	TURBULENCE 		= 0.3;
int 	LIFE_MIN 		= 200;
int 	LIFE_MAX 		= 1000;
int 	WEIGHT 			= 3;

color[] COLORS 			= {	color(255,0,0, 100),
							color(255,100,0, 180),
							color(255),
							color(255, 200),
							color(0,100,255, 180) };

// color[] COLORS		= {color(255,0), color(255), color(255,0)}; // alphascale

color 	BGCOLOR 		= 0;
// color BGCOLOR 		= #221DC2; // IKB

PSystem ps;
float rot = 0;
int mode = 1;
boolean looping = true;

void setup() {
		size(1280, 720);
		if (CENTER_ORIGIN) ORIGIN = new PVector(width/2, height/2);
	
		init();
		background(BGCOLOR);
		noCursor();
}

void init() {
		// PSystem(int pnum, int pemit_w, int pemit_h, float pvel, float pturbo, int plife_min, int plife_max, color[] pcolors)
		ps = new PSystem(NUM_PARTICLES,			// particle NUMBER
						 EMMITER.x, EMMITER.y,	// EMMITER ORIGIN area
						 SPEED_MAX, TURBULENCE,	// speed range, TURBULENCE
						 LIFE_MIN, LIFE_MAX);	// min, max life			 

		ps.setWeight(WEIGHT);	// particle weight range
		ps.setColors(COLORS);	// set colors
		ps.start(VELOCITY);		// optional VELOCITY vector
}

void draw() {
		// trails thingy:
		fill(BGCOLOR, 64);
		noStroke();
		rect(0,0,width,height);
		noFill();

		// translate, update, display:
		pushMatrix();
		translate(ORIGIN.x, ORIGIN.y);
		if (CENTER_ORIGIN) {
			rot += ROTATION;
			if (rot > 360) rot -= 360;
			rotate(radians(rot));	
		}
		

		ps.update();
		ps.display();

		popMatrix();

		if (mousePressed && CENTER_ORIGIN) {
			ORIGIN.x = mouseX;
			ORIGIN.y = mouseY;
		}
}

void keyReleased() {
		// random colors
		if (key == 'c' || key == 'C') {
			for (int i = 0; i < ps.colors.length; i++) {
				float ra = map(i,0,ps.colors.length-1, 100,255);
				float rk = random(0, 255-ra);
				ps.colors[i] = color(random(rk,255),random(rk,255),random(rk,255), ra);
				COLORS[i] = ps.colors[i];
			}
		}

		// reset
		if (key == '|') {
			init();
		}
		if (key == '\\') {
			setup();
		}
		if (key == 'P' || key == 'p') {
			if (looping) {
				looping = false;
				noLoop();
			} else {
				looping = true;
				loop();
			}
			
		}

		// switch mode
		if (key == 'm' || key == 'M') {
			mode = 0-mode;
			if (mode > 0) {
				EMMITER 		= new PVector(128, 72);
				ORIGIN 			= new PVector(0, 0);
				CENTER_ORIGIN 	= true;
				VELOCITY 		= new PVector(0, 0); // 0, 0 : away from CENTER
				ROTATION		= 0.1;
			} else {
				EMMITER 		= new PVector(1280, 72);
				ORIGIN 			= new PVector(640, 0);
				CENTER_ORIGIN 	= false;
				VELOCITY 		= new PVector(0, 2); // 0, 0 : away from CENTER
				ROTATION		= 0;
			}
			setup();
		}
}

void keyPressed() {
		if (key == ' ') redraw();
		// speed
		if (keyCode == UP && SPEED_MAX < 20) {
			SPEED_MAX += 0.25;
			ps.setSpeed(SPEED_MAX);
		}
		if (keyCode == DOWN && SPEED_MAX > 1) {
			SPEED_MAX -= 0.25;
			ps.setSpeed(SPEED_MAX);
		}
		// rotation
		if (keyCode == LEFT && ROTATION > -5) {
			ROTATION -= 0.1;
		}
		if (keyCode == RIGHT && ROTATION < 5) {
			ROTATION += 0.1;
		}
		// weight
		if (key == 'w' && WEIGHT < 20) {
			WEIGHT++;
			ps.setWeight(WEIGHT);
		}
		if (key == 'W' && WEIGHT > 1) {
			WEIGHT--;
			ps.setWeight(WEIGHT);
		}
		// turbulence
		if (key == 't' && TURBULENCE < 3) {
			TURBULENCE+=0.01;
			ps.setTurbo(TURBULENCE);
		}
		if (key == 'T' && TURBULENCE > 0) {
			TURBULENCE-=0.01;
			ps.setTurbo(TURBULENCE);
		}

}
