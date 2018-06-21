public class Button {
  final float x, y, w, h;
  int a, b, c; // The color
  public Button(float x, float y, float w, float h, int a, int b, int c) {

    // X and Y position
    this.x = x;
    this.y = y;

    // Dimensions
    this.w = w;
    this.h = h;

    // The color
    this.a = a;
    this.b = b;
    this.c = c;
  }

  public boolean overBut(float X, float Y) {
    if (X >= x && X <= x+w && 
      Y >= y && Y <= y+h) {
      return true;
    } else {
      return false;
    }
  }

  public void show() {
    stroke(255);
    fill(a, b, c);
    rect(x, y, w, h);
    stroke(0);
  }
}
