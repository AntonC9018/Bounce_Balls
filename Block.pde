public class Block {
  final float w, h;
  final int MAX_COUNT;
  PVector pos;
  float x, y;
  boolean alive;
  int count;
  float c;
  int val;
  int hitFrames;

  boolean highlight;

  Integer mils;

  Block (int col, int row, float W, float H, int c) {
    x = col;
    y = row;
    w = W;
    h = H;
    calcPos();
    MAX_COUNT = count = c;

    alive = true;
    val = (int)random(200);
  }

  public void newColor() {

    if (val == 200) val = 0;
    val ++;
  }

  public void show() {
    colorMode(HSB, 200, 100, 100);
    fill(val, 80, 80);

    if (highlight) {
      hitFrames++;
      if (hitFrames > 4)
      {
        highlight = false;
        grid.toHighlight.remove(this);
      }
    }

    rect(pos.x, pos.y, w, h);
    fill(0);
    if (count > 99)
      textSize(w * 1.4 * 1/ (int)(Math.log10(count) + 1));
    else
      textSize(w * 0.6);
    text(count, pos.x + w/2, pos.y + h/2 - textDescent() / 2);
  }

  // update count and score
  public void hitB(Ball b) {
    if (!alive) return; 
    if (lastHit != countTimes) b.hitcount++;
    lastHit = countTimes;
    if (b.imag) return;

    gg.score++;
    count--;

    if (count <= 0) {
      alive = false;
      return;
    }

    newColor();
    hitFrames = 0;
    highlight = true;
    grid.toHighlight.put(this, this);
  }

  void calcPos() {
    pos = new PVector(x * w, y * h);
  }

  void highlight() {
    println("calling highlight()");
    rect(pos.x, pos.y, w, h);
  }
}
