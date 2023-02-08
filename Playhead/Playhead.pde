/*
   ____   __                 __       __  ___              _   
  / __/__/ /_ _____ ________/ /__    /  |/  /__  _______ _(_)__
 / _// _  / // / _ `/ __/ _  / _ \  / /|_/ / _ \/ __/ _ `/ (_-<
/___/\_,_/\_,_/\_,_/_/  \_,_/\___/ /_/  /_/\___/_/  \_,_/_/___/
 
 * Playhead
 * by Eduardo Morais 2019 - www.eduardomorais.pt
 *
 * Use arrow keys to control speed and number of dots
 */


import processing.sound.*;

TriOsc oscil, oscil2;
Env env; 

int plhead = 1000;
int notesnum = 16;
ArrayList<Dot> notes;
float v = 2;
float[] freqs = {
  329, 415, 494, 277.18, 349.23, 416, 493, 329.63, 415.3, 493.88
  };
  
  
void setup() {
	size(1024, 1024);
	background(255);
  smooth();

	oscil = new TriOsc(this);
	oscil2 = new TriOsc(this);
	env  = new Env(this);

	notes = new ArrayList<Dot>();
	for (int i = 0; i < notesnum; i++) {
		addnote();
	}
	notesYcalc();
}

void addnote() {
  	float nvel = random (0.5, 1.5);
  	color nc = color(random(0,150),random(50,150),random(100, 255));
  	int nf = int(random(0, freqs.length));

    //   Dot(float px, float py, float pvel, color pc, float pd, float pfreq) 
    notes.add(new Dot(random(-width, -50), height/2, nvel, nc, random(30, 50), freqs[nf]));
}

void notesYcalc() {
	for (int i = 0; i < notes.size(); i++) {
		Dot note = notes.get(i);
		float ny = map(i, 0, notes.size()-1, height/2 - 50, 50);
		if (i%2 == 0) ny = height-ny;
		note.y = ny;
	}
}


void draw() {
	fill(255,30);
	rect(0,0,width,height);

	// update
	plhead = mouseX;
	for (int i = 0; i < notes.size(); i++) {
		Dot note = notes.get(i);
		note.update(v);
	}

	// display
	stroke(255,0,0, 16);
	strokeWeight(2);
	line(plhead,0,plhead,height); // playhead 

	int cur = 0;
	for (int i = 0; i < notes.size(); i++) {
		Dot note = notes.get(i);
		cur += note.display();
	}
	if (cur > 0) { cursor(HAND); } else { cursor(ARROW); }

}

void keyPressed() {
	if (keyCode == LEFT && v > 0.5) {
		v -= 0.2;
	}
	if (keyCode == RIGHT && v < 4) {
		v += 0.2;
	}
	if (keyCode == UP && notesnum < 64) {
		notesnum++;
		addnote();
		notesYcalc();
	}
	if (keyCode == DOWN && notesnum > 4) {
		notesnum--;
		int r = 0;
		float minx = 0;
		for (int i = 0; i < notes.size(); i++) {
			Dot note = notes.get(i);
			if (note.x < minx) {
				minx = note.x;
				r = i;
			}
		}
		notes.remove(r);
	}
}
