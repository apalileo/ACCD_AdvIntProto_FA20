// A hybridization of Daniel Shiffman's Flocking Boids and Metaballs
// Now with serial inputs!

import processing.serial.*;

Serial myPort;
int lf = 10;
String inString = "";

Point[] points = new Point[40];

float alignValue = .5;
float cohesionValue = 0;
float separationValue = 1;
float speedValue = 5;
float colorValue = 220;
float spreadValue = 55;
String bpmValue = "";
String tempValue = "";
boolean dataIn = false;

void setup() {
  size(640, 360);
  background(0);

  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil(lf);

  colorMode(HSB, 360, 100, 100, 100);
  for (int i = 0; i < points.length; i++) {
    points[i] = new Point(random(width), random(height));
  }
}

void draw() {
  background(0);
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int index = x + y * width;
      float sum = 0;
      for (Point point : points) {
        float d = dist(x, y, point.position.x, point.position.y);
        sum += spreadValue * point.r / d;
      }
      pixels[index] = color(constrain(sum, 0, colorValue), 100, 100, 100);
    }
  }

  updatePixels();

  for (Point point : points) {
    point.group(points);
    point.update();
    //point.show();
  }
  fill(100);
  noStroke();
  rect(0, height-30, width, 30);

  if (dataIn == true) {  
    String bpmText = "Heart Rate: " + bpmValue + "BPM";
    String tempText = "Temperature: " + tempValue + "°F";
    fill(360);
    text(bpmText, 20, height - 10);
    text(tempText, 140, height - 10);
  }
}

void serialEvent(Serial p) {
  inString = p.readString();

  if (inString != null) {
    String[] data = split(trim(inString), ",");
    printArray(data);

    dataIn = true;
    colorValue = map(float(data[0]), 75, 100, 180, 260);
    tempValue = data[0];
    speedValue = map(float(data[1]), 70, 120, 1, 10);
    bpmValue = data[1];
    if (float(data[2]) <= 1400) {
      cohesionValue = map(float(data[2]), 0, 1400, -0.5, 0.6);
    }
    if (float(data[2]) > 1400) {
      cohesionValue = map(float(data[2]), 1401, 3800, 0.6, -0.5);
    }
  }
}
