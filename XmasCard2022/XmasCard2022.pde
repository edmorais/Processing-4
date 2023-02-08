// inits
size(900,900);
background(64);
color[] cols = new color[7];

// config vars
cols[0] = color(#FFFFFF); // background 
cols[1] = color(#FB573B); // xmas-themed colors
cols[2] = color(#4F393C);
cols[3] = color(#8EA88D);
cols[4] = color(#9CD0AC);
cols[5] = color(#FB573B);
cols[6] = color(#F4EB9E);

int s = 100; // cell size
int sratio = 5; // foreground ratio
PGraphics im = createGraphics(3860, 3860); // width, height
String name = "xmas_bg";
String format = "png";

// begin
im.beginDraw();
im.background(cols[0]);
im.strokeWeight(s/sratio);
im.smooth();

// draw pattern
for (int iy = 0; iy < im.height; iy += s) {
    
    /*

    */
    im.ellipseMode(CORNER);
    for (int ix = 0; ix < im.width; ix += s) {
        im.stroke(cols[int(random(1,6))]);
        int r = int(random(0,110));
        if (r < 20) {
            im.line(ix,iy+s,ix+s,iy);
        } else if (r < 40) {
            im.line(ix,iy,ix+s,iy+s);
        } else if (r < 70) {
           // im.line(ix,iy+s/2,ix+s,iy+s/2);
            im.stroke(cols[int(random(1,6))]);
            im.noFill();
            im.ellipse(ix+s*.3,iy+s*.3,s*.4,s*.4);
        } else if (r < 100) {
            im.line(ix+s/2,iy,ix+s/2,iy+s);
        } else {
            if (random(0,10) > 7) {
                im.noStroke();
            }
            im.fill(cols[int(random(1,6))]);
            im.ellipse(ix+s*.2,iy+s*.2,s*.6,s*.6);
        }
    }
}

// save
im.endDraw();
im.save(name+"_"+im.width+"x"+im.height+"."+format);

// Display image
if (im.width > im.height) {
  image(im, 0, (height-height*float(im.height)/float(im.width))/2, width, height*(float(im.height)/float(im.width)));
} else {
  image(im, (width-width*float(im.width)/float(im.height))/2, 0, width*(float(im.width)/float(im.height)), height);
}
