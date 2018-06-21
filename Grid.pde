import java.util.Arrays;
import java.util.HashSet;

public class Grid {
  Block [][] grid;
  ArrayList <Block> bl;
  final float d;
  final int howmany;

  public Grid(int howmany) {
    println("Hey");
    grid = new Block[howmany][howmany];
    bl = new ArrayList <Block> ();
    //Arrays.fill(grid, null);
    this.howmany = howmany;
    d = getDim();

    shift();
  }

  private float getDim() {
    if (width != height) {
      return -1;
    } else {
      return (width / howmany);
    }
  }

  void showBlocks() {

    textSize(d * 0.8);
    textAlign(CENTER, CENTER);

    for (Integer i = bl.size() - 1; i >= 0; i--) {
      if (bl.get(i).alive)  
        bl.get(i).show();
      else 
      killBl(i);
    }
  }
  void killBl(Integer i) {
    if (animatingBlocks) return;
    Block temp = bl.get(i);
    grid[round(temp.x)][round(temp.y)] = null;
    bl.remove((int)i);
    toHighlight.remove(temp);
    i--;
  }

  public ArrayList<Block> command(Ball b) {

    float Y = b.pos.y;

    // there is no collision if the ball went off the screen
    if (Y > height) return null;

    float X = b.pos.x;

    // left or right
    float lr = X / d;

    // up or down
    float up = Y / d;

    // radius of the ball in terms of grid coordinates
    // i.e. real coordinates over dimensions of each cell
    float littleR = b.r / d;

    int x1, x2, y1, y2;

    //  Ball's current location
    x1 = floor(lr);
    y1 = floor(up);

    x1 = (x1 > 6) ? 6 : (x1 < 0) ? 0 : x1;
    y1 = (y1 > 6) ? 6 : (y1 < 0) ? 0 : y1;

    if (floor(lr + littleR) > x1 && x1 < 6) {
      x2 = x1 + 1;
    } else if (floor(lr - littleR) < x1 && x1 > 0) {
      x2 = x1 - 1;
    } else x2 = -1;

    if (floor(up + littleR) > y1 && y1 < 6) {
      y2 = y1 + 1;
    } else if (floor(up - littleR) < y1 && y1 > 0) {
      y2 = y1 - 1;
    } else y2 = -1;


    // if the ball hit the left or the right wall
    if (x1 == 0 && x2 == -1) b.lWall();
    else b.lw = false;

    if (x1 == 6 && x2 == -1) b.rWall();
    else b.rw = false;


    // if the ball hit the upper wall
    if (y1 == 0 && y2 == -1) b.upWall();
    else b.uw = false;

    ArrayList <Block> blah = new ArrayList <Block>();
    if (grid[x1][y1] != null) 
      blah.add(grid[x1][y1]);

    if (x2 != -1 && y2 == -1) {
      if (grid[x2][y1] != null)
        blah.add(grid[x2][y1]);
    } else if (x2 == -1 && y2 != -1) {
      if (grid[x1][y2] != null)
        blah.add(grid[x1][y2]);
    } else if (x2 != -1 && y2 != -1) {
      if (grid[x1][y2] != null)
        blah.add(grid[x1][y2]); 

      if (grid[x2][y1] != null)
        blah.add(grid[x2][y1]);

      if (grid[x2][y2] != null)
        blah.add(grid[x2][y2]);
    }

    if (blah.size() == 0)
      return null;
    else return blah;
  }

  void shift() {
    //for (int j = 0; j < howmany; j++) 
    //  for (int i = 0; i < howmany; i++) 
    //    if (grid[i][j] == null) println("null"); 
    //    else println(grid[i][j]);
    if (grid == null) println("null");

    for (int i = 0; i < howmany; i++) {
      if (grid[i][howmany - 2] != null) {
        println("numBalls = 0");
        numBalls = -1;
      }
    }
    Block[][] gridCopy = new Block[howmany][howmany];

    for (int j = 0; j < howmany; j++) {
      for (int i = 0; i < howmany; i++) {
        gridCopy[i][j] = grid[i][j];
        grid[i][j] = null;
      }
    }

    for (int j = 1; j < howmany - 1; j++) {
      for (int i = 0; i < howmany; i++) {
        grid[i][j] = gridCopy[i][j-1];
      }
    }

    spawnBlocks();
    animatingBlocks = true;
  }

  float wh = 0;
  float animRate = 0.05;

  void animateBlocks() {
    for (Block b : bl) {
      b.y += animRate;
      b.calcPos();
    }
    wh += animRate;

    if (wh >= 1) {
      animatingBlocks = false;
      wh = 0;
      for (Block b : bl) {
        b.y = round(b.y);
        b.calcPos();
      }
    }
  }


  float theOdds = 0.32f;
  float scoreBreach = 1.2f;

  void spawnBlocks() {
    HashSet <Integer> s = new HashSet <Integer>();
    do {
      for (int i = 0; i < howmany; i++) {
        if (random(1) < theOdds)
          s.add(i);
      }
    } while (s.size() < 1);

    for (int i = 0; i < howmany; i++) {
      if (s.contains(i)) {
        grid[i][0] = new Block(i, -1, d, d, 
          (int)(random(scoreBreach) * numBalls) + numBalls);
        bl.add(grid[i][0]);
      }
    }
  }

  HashMap <Block, Block> toHighlight = new HashMap  <Block, Block>();

  void highlightBlocks() {
    colorMode(HSB, 360, 100, 100);
    stroke(41, 80, 80);
    fill(36, 80, 80, 100);
    strokeWeight(3);

    for (Block i : toHighlight.keySet()) {
      i.highlight();
    }
    stroke(0);
    strokeWeight(1);
    fill(255);
  }
}
