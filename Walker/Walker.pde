/*
 * Walker -- after The Nature of Code
 * by Eduardo Morais / May 2021 - www.eduardomorais.pt
 */

import java.util.Random;

Rando w;

void setup() {
	size(1024,1024);
	background(#221DC2);
	stroke(255);
	strokeWeight(1);
	w = new Rando();
}


void draw() {
	w.walk();
	w.display();
}

void keyReleased() {
	w = new Rando();
}

void mouseReleased() {
	w.attract();	
}

class Rando {
	int x;
	int y;
	int px;
	int py;
	int mx;
	int my;
  Random genera;

	Rando(int posx, int posy) {
		x = posx;
		y = posy;
		mx = x;
		my = y;
    genera = new Random();
	}

	Rando() {
		this(width/2, height/2);
	}

	void attract() {
		mx = mouseX;
		my = mouseY;
	}

	void walk() {
		px = x;
		py = y;
		int sx, sy;
		sx = mx > x ? 1 : -1;
		sy = my > y ? 1 : -1;

		sx = mx==x ? 0 : sx;
		sy = my==y ? 0 : sy;

    float num = (float) genera.nextGaussian();
		x += num*10 + sx;
    num = (float) genera.nextGaussian();
		y += num*10 + sy;

	}

	void display() {
    stroke(255, 128);
    strokeWeight(1);
    noFill();
		line(px,py, x,y);
    fill(255, 64);
    noStroke();
    ellipse (x,y,8,8);
	}

}
