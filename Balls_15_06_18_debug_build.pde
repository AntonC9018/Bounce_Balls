import java.util.Arrays;

ArrayList <Ball> b; // Balls that can damage blocks
int n = 7; // Dimensions of the grid (N x N)
Grid grid; // Grid stores information about blocks
ArrayList <PVector> points; // Buffer for saving computing power
PVector a; // Mouse's previous location
float r = 12; // radius of balls
Button but, but2, but3;
int start = 60; // starting frameRate
int speed = 7; // magnitude of the velocity vector of all balls
boolean notTrace = false; // whether or not to draw the path
float corn; // const of corners
int lastHit = -1;

PVector curPos;
PVector posBuffer;

int numBalls;

PVector tempPos, tempVel;
boolean gening = false;
int framesUndergoneSinceTheFirstBallWasCreated;

boolean changedLoc = false;

boolean animatingBlocks = false;

boolean lose = false;

int countTimes;

void settings() {
  size(525, 525, P2D);
  smooth();
}

void setup() {
  frameRate(start);
  reset();


  but = new Button (20, height - 30, 20, 20, 50, 205, 50);
  but2 = new Button (80, height - 30, 20, 20, 205, 0, 0);
  but3 = new Button (50, height - 30, 20, 20, 255, 255, 0);


  corn = r / 2;
}

void reset() {

  notTrace = false;
  lose = false;
  animatingBlocks = false;
  changedLoc = false;
  gening = false;
  numBalls = 1;

  grid = new Grid(n);

  points = new ArrayList <PVector>();
  a = new PVector(0, 0);
  curPos = new PVector(width/2, height - r);
  posBuffer = curPos;

  PFont f = createFont("Arial", 64);
  textFont(f);

  fill(255);

  b = null;
}

void draw() {
  background(0);


  grid.showBlocks();  
  grid.highlightBlocks();

  colorMode(RGB, 255, 255, 255);
  textAlign(LEFT, CENTER);
  textSize(25);
  fill(255);
  text("Score " + gg.score, 10, 18);
  ellipse(width - 100, 20, r * 2, r * 2);
  if (numBalls < 1000)
    text("x " + numBalls, width - 80, 18);
  else 
  text("x 10^" + round((float)Math.log10(numBalls)), width - 80, 18);


  but.show();
  but2.show();
  but3.show();

  if (animatingBlocks) {
    grid.animateBlocks();
    ellipse(curPos.x, curPos.y + r/2, r * 2, r * 2);
    return;
  }

  if (lose) {
    lose(); 
    return;
  }

  if (gening && framesUndergoneSinceTheFirstBallWasCreated % 10 == 0) 
    genBall();

  framesUndergoneSinceTheFirstBallWasCreated++;



  // grid.drawGrid();

  // move and draw the ball if it exists

  boolean stop = true;
  if (b != null)
    for (int i = 0; i < b.size(); i++) {
      if (!b.get(i).off) {
        stop = false;
        b.get(i).show();
        actBall(b.get(i));
      } else {
        if (!changedLoc) {
          changedLoc = true;
          posBuffer = new PVector(b.get(i).pos.x, height - r);
        }
      }
    }

  if (stop && !gening) {
    if (changedLoc) {

      numBalls++;
      grid.shift();
      //grid.spawnBlocks();

      if (numBalls == -1) lose = true;
    }
    curPos = posBuffer;
    changedLoc = false;
    fill(255);
    showTrace();
    ellipse(curPos.x, curPos.y + r/2, r * 2, r * 2);
    b = null;
  }
}

void actBall(Ball b) { 
  b.checkB(grid.command(b));
  b.move();

  if (b.pos.y > height + b.r) {
    b.off = true;
  }
}

void showTrace() {
  if (notTrace) return;
  fill(255);
  // number of pixels for the cursor to pass to redraw the path
  float s = 0.5;
  // do not recalculate the path unless X seconds have elapsed
  int f = frameCount % 2;// <-X

  if ((a != null) && (a.x < mouseX + s && a.x > mouseX - s && 
    a.y < mouseY + s && a.y > mouseY - s) || f != 0) {  
    // how small the path will be compared to the balls radius
    float sizer = 0.8 * r;

    for (int i = 0; i < points.size(); i++) {
      PVector p = points.get(i);
      ellipse(p.x, p.y, sizer, sizer);
    }
  } else {
    // number of MAX points to draw
    int MAX = 25;
    // the spacing between the individual path-showing circles
    int path = 5;
    // number of bounces for the ball to stop tracing its path
    int n = 2;
    points.clear();
    a = new PVector (mouseX, mouseY);
    PVector origin = new PVector(curPos.x, curPos.y);
    PVector vel = calcVel(origin, speed, a.x, a.y);
    countTimes = 0;
    Ball ball = new Ball (origin, vel, r, true, corn);
    ball.setDoneAt(n);

    int i = 0;
    while (!ball.done()) { 
      if (countTimes % path == 0) {
        ball.show();
        points.add(ball.pos.copy());
        i++;
      }
      countTimes ++;
      actBall(ball);
      if (i > MAX) return;
    }
  }
}


PVector calcVel(PVector origin, float vel, float x, float y) {
  float theta = atan2(y - origin.y, x - origin.x);
  return new PVector(
    (vel) * cos(theta), 
    (vel) * sin(theta));
}

void mouseReleased() {
}

void keyPressed() {
}

void keyReleased() {
  if (keyCode == 32) { // SPACEBAR
    if (b == null) {
      b = new ArrayList <Ball> ();
      tempPos = new PVector(curPos.x, curPos.y);
      tempVel = calcVel(tempPos, speed, mouseX, mouseY);
      gening = true;
      framesUndergoneSinceTheFirstBallWasCreated = 0;
      a = null;
      changedLoc = false;
    } else { 
      if (!changedLoc) {
        posBuffer = new PVector(b.get(0).pos.x, height - r);
      }
      b = null;
      gening = false;
      tempPos = null;
      tempVel = null;
    }
  }
}

void mousePressed() {
  if (lose) {
    reset(); 
    return;
  }

  if (but.overBut(mouseX, mouseY)) {
    frameRate(frameRate * 2);
    return;
  }
  if (but2.overBut(mouseX, mouseY)) {
    frameRate(frameRate / 2);
    return;
  }
  if (but3.overBut(mouseX, mouseY)) {
    frameRate(start);
    return;
  }

  if (b == null) {
    b = new ArrayList <Ball> ();
    tempPos = new PVector(curPos.x, curPos.y);
    tempVel = calcVel(tempPos, speed, mouseX, mouseY);
    gening = true;
    framesUndergoneSinceTheFirstBallWasCreated = 0;
    a = null;
    changedLoc = false;
  } else { 
    if (!changedLoc) {
      posBuffer = new PVector(b.get(0).pos.x, height - r);
    }
    b = null;
    gening = false;
    tempPos = null;
    tempVel = null;
  }
}

void genBall() {
  if (b != null && b.size() < numBalls) {
    b.add(new Ball(tempPos.copy(), tempVel.copy(), r, false, corn));
  } else {
    tempPos = null;
    tempVel = null;
    gening = false;
  }
}

void lose() {
  text("U LOSE", 50, 50);
}
//}
