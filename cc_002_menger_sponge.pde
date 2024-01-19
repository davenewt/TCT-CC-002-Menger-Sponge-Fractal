import peasy.*;
PeasyCam cam;

float boxWidth; // size of the Menger Sponge fractal box
float rotX, rotY, rotZ, rotSpeed; // rotation of box
boolean displayInfo = true; // show or hide HUD/info text. Toggled via keyReleased()
boolean rotating = true; // is the box rotating (animated)?
float sep = 1.0; // initial separation value
float sepM; // multiplier for separation value
float cycle = -PI/2; // increment this up to TWO_PI and use sin() to get a value from -1 to 1
float iterations; // incremented each, well, iteration! Initialized in setup()
float maxIterations = 3; // make sure things don't slow to a crawl!
PFont f; // font for displaying text / info
StringList welcomeText; // will hold the text to be displayed
ArrayList<Box> sponge;
int m, secs; // used for milliseconds since sketch started
int savingFrames = -1; // is the sketch saving frames out as images?
int savingCounter = 0; // keep track of frames being saved

void setup() {
  //size(600, 600, P3D);
  fullScreen(P3D);
  boxWidth = width/2;

  frameRate(60); // 30 = good for saving frames for GIFs
  rotSpeed = 3000; // or fps 30 and rotSpeed 300 for windowed

  cam = new PeasyCam(this, width/2, height/2, 0, width);
  cam.setMinimumDistance(width-width/2);
  cam.setMaximumDistance(width+width/3);

  welcomeText = new StringList();
  welcomeText.push("Welcome to my version of The Coding Train's second coding challenge: Menger Sponge Fractal!");
  welcomeText.push("You can find the code at github.com/davenewt/TCT-CC-002-Menger-Sponge-Fractal");
  welcomeText.push("Below are the controls you can use, and some live info!");
  f = createFont("Courier", 40, false); // Create font at size 40, display later at size 20. Last arg 'true' or 'false' = smoothing

  sponge = new ArrayList<Box>();
  Box b = new Box(0, 0, 0, boxWidth); // set box size to 300 if using a 600px window
  sponge.add(b);
  iterations = 0;
}

//void mousePressed() {
//  // start exporting frames, for one full cycle (# of frames = rotSpeed)
//  savingFrames *= -1;
//  println(savingFrames);
//}

void keyReleased() {
  println("KeyCode: "+keyCode);
  //println("Iterations: "+iterations);
  if (keyCode == 73) { // 'i'
    displayInfo = !displayInfo;
  } else if (keyCode == 80) { // 'p'
    rotating = !rotating;
  } else if (keyCode == 39) { // right arrow
    if (iterations < maxIterations) {
      iterations++;
      makeBoxes();
    }
  } else if (keyCode == 37) { // left arrow
    if (iterations > 0) {
      iterations--;
      makeBoxes();
    }
  }
}

void makeBoxes() {
  sponge = new ArrayList<Box>();
  Box b1 = new Box(0, 0, 0, boxWidth);
  sponge.add(b1);
  for (int i = 0; i < iterations; i++) {
    // For each generation, create an ArrayList of Box objects called 'next' (temporary, will later get put into the sponge)
    ArrayList<Box> next = new ArrayList<Box>();
    // For every Box object (b2) in the sponge, generate all of its child boxes and put them in the 'next' ArrayList
    for (Box b2 : sponge) {
      ArrayList<Box> newBoxes = b2.generate();
      next.addAll(newBoxes);
    }
    // Put all of the 'next' boxes into the sponge (replacing what was already there)
    sponge = next;
  }
}

void draw() {
  if (iterations > 0) {
    // start calculating separation amount (from 0) when there are multiple cubes
    // for a smooth transition when switching from one cube to multiple.
    // map the multiplier between 1 (no space between boxes) and a larger number.
    sepM = map(sin(cycle), -1, 1, 1, 3); // 1.5 = good last value
    //println (sepM); // checking this changes as expected
    cycle += (TWO_PI/rotSpeed);
    if (cycle > TWO_PI) {
      cycle = 0;
    }
  } else if (iterations == 0) {
    cycle = -PI/2; // reset/lock cycle value so separation will be 0 when iterating again
  }

  background(0);
  stroke(127);
  noFill();
  ambientLight(255, 255, 255); // pure white light so colours will pop!

  pushMatrix();
  translate(width/2, height/2);
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);
  for (Box b : sponge) {
    b.show();
  }
  popMatrix();

  // Change rotation of box
  if (rotating) {
    // lock to TWO_PI so we'll get a full rotation in rotSpeed # of frames
    rotX += TWO_PI/rotSpeed;
    rotY += 0;
    rotZ += TWO_PI/rotSpeed;
    //println("rotX: "+rotX+"rotY: "+rotY+"rotZ: "+rotZ);
  }

  if (displayInfo) {
    // Draw text flat on the window with cam.beginHUD() and cam.endHUD [similar to pushMatrix() and popMatrix()]
    cam.beginHUD();
    textSize(20);
    textAlign(LEFT);
    textFont(f, 20);
    fill(0, 150, 255);
    m = millis(); // milliseconds since the sketch started running
    secs = floor(m/1000); // convert to plain seconds
    int lineToShow = floor(secs/10); // secs/x, where x = number of seconds to display each line of info for.
    if (lineToShow < 0) {
      lineToShow = 0;
    } else if (lineToShow > welcomeText.size()-1) {
      lineToShow = welcomeText.size()-1;
    }
    String firstLine = welcomeText.get(lineToShow);
    String displayText = firstLine + "\n" + 
      "Left/Right arrow: -/+ iterations (current: " + floor(iterations) + ", max "+floor(maxIterations)+").  " +
      "[p] = Pause rotation.  [i] hide/show this.  " +
      "FPS: " + floor(frameRate);
    text(displayText, 30, height-50);
    //text(s, 40, 40, 280, 320);  // Text wraps within text box
    cam.endHUD();
  }

  if ((savingFrames == 1) && (savingCounter < rotSpeed)) {
    // save a frame!
    println("Saving frame "+(savingCounter+1)+" of "+floor(rotSpeed));
    saveFrame("output/frame-#####.png");
    savingCounter++;
    if (savingCounter > rotSpeed) {
      println("Finished saving frames.");
      savingCounter = 0;
      savingFrames *= -1;
      exit();
    }
  }
}
