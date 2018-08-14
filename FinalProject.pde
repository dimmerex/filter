import blobDetection.*;
import processing.video.*;

Capture video;

PImage pic;
PImage pic2;
PImage pic3;
color trackColor; 
color trackColor2;
//Threshold of color 
float threshold = 30;
//Size of blobs
float distThreshold = 15;
float X;
float Y;
boolean mouseClicked = false; 


ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> blobs2 = new ArrayList<Blob>();

void setup() {
  size(640, 480);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, width, height, 30);
  video.start();
  trackColor = color(255, 0, 0);
  trackColor2 = color(255, 0, 0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  video.loadPixels();
  image(video, 0, 0);

  blobs.clear();
  blobs2.clear();

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      color currentColor2 = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      float r3 = red(currentColor2);
      float g3 = green(currentColor2);
      float b3 = blue(currentColor2);
      float r4 = red(trackColor2);
      float g4 = green(trackColor2);
      float b4 = blue(trackColor2);

      float d = distSq(r1, g1, b1, r2, g2, b2); 
      float d2 = distSq(r3, g3, b3, r4, g4, b4);

      if (d < threshold*threshold) {

        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
      }
        if (d2 < threshold*threshold) {

        boolean found = false;
        for (Blob b : blobs2) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          blobs2.add(b);
        }
      }
    }
  }
  
  boolean color1Found = false;
  boolean color2Found = false;
  
  //
  float meanX = 0, meanY = 0, A = 0, B = 0, pointX = 0, pointY = 0;
  if (blobs.size() > 0) {
    
    color1Found = true;
  
    float sumX = 0;
    float sumY = 0;
    int n = 0;
    for (Blob b : blobs) {
      if (b.size() > 500) {
        sumX += (b.minx + b.maxx)/2;
        sumY += (b.miny + b.maxy)/2;
        n++;
      }
    }
    meanX = sumX/n;
    meanY = sumY/n;
    
    float numer = 0;
    float denom = 0;
    for (Blob b : blobs) {
      if (b.size() > 500) {
        float x = (b.minx + b.maxx)/2;
        float y = (b.miny + b.maxy)/2;
        numer += (x-meanX)*(y-meanY);
        denom += (x-meanX)*(x-meanX);
      }
    }
    A = numer/denom;
    
    B = meanY - A*meanX; 
    
    pointY = 0;
    pointX = (float)((pointY-B)/A);
  
  }
  
  //
  
  float meanX2 = 0, meanY2 = 0, A2 = 0, B2 = 0, pointX2 = 0, pointY2 = 0;
  if (blobs2.size() > 0) {
    
    color2Found = true;
  
    float sumX = 0;
    float sumY = 0;
    float n = 0;
    for (Blob b : blobs2) {
      if (b.size() > 500) {
        sumX += (b.minx + b.maxx)/2;
        sumY += (b.miny + b.maxy)/2;
        n++;
      }
    }
    meanX2 = sumX/n;
    meanY2 = sumY/n;
    
    float numer = 0;
    float denom = 0;
    for (Blob b : blobs2) {
      if (b.size() > 500) {
        float x = (b.minx + b.maxx)/2;
        float y = (b.miny + b.maxy)/2;
        numer += (x-meanX2)*(y-meanY2);
        denom += (x-meanX2)*(x-meanX2);
      }
    }
    A2 = numer/denom;
    
    B2 = meanY2 - A2*meanX2; 
    
    pointY2 = 0;
    pointX2 = (float)((pointY2-B2)/A2);
  
  }
  
//Draw blobs  

  /*for (Blob b : blobs) {
    if (b.size() > 500) {
      b.show();
    }
  }
  for (Blob b : blobs2) {
    if (b.size() > 500) {
      b.show();
    }
  }
 */
  
  //Draw guide lines
  //line(meanX, meanY, pointX, pointY);
  //line(meanX2, meanY2, pointX2, pointY2);
  
pic = loadImage("data/Red.png");
pic2 = loadImage("data/Blue.png");

if (color1Found) {
  X = meanX;
  Y = meanY;
  PVector v1 = new PVector(pointX-X, pointY-Y);
  PVector v2 = new PVector(1, 0); 
  float c = PVector.angleBetween(v1, v2);
  
  translate(X,Y);
  rotate(-(c-PI/2));
  image(pic,-24,-750);
  rotate(c-PI/2);
  translate(-X,-Y);
}

if (color2Found) {
  X = meanX2;
  Y = meanY2;
  PVector v1 = new PVector(pointX2-X, pointY2-Y);
  PVector v2 = new PVector(1, 0); 
  float c = PVector.angleBetween(v1, v2);
  
  translate(X,Y);
  rotate(-(c-PI/2));
  image(pic2,-24,-750);
  rotate(c-PI/2);
  translate(-X,-Y);
}

if (color1Found && color2Found) {
  float xi = (B2 - B) / (A - A2);
  float yi = A * xi + B;
  
   pic3 = loadImage("data/Spark.png");
    if ((xi > min(meanX, pointX)) && (xi < max(meanX, pointX)) && (yi > min(meanY, pointY)) && (yi < max(meanY, pointY))
      && (xi > min(meanX2, pointX2)) && (xi < max(meanX2, pointX2)) && (yi > min(meanY2, pointY2)) && (yi < max(meanY2, pointY2))) {
      image(pic3, xi-width/2+185, yi-height/2+85);
      }
}

}
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}


void mousePressed() {
 if (mouseClicked == false) {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
mouseClicked = true;
} else {
  int loc = mouseX + mouseY*video.width;
  trackColor2 = video.pixels[loc];
mouseClicked = false;
}

}