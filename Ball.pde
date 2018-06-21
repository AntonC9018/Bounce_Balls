import java.util.Arrays;

enum R {
  UP_RIGHT_CORNER(true), 
    UP_LEFT_CORNER(true), 
    DOWN_RIGHT_CORNER(true), 
    DOWN_LEFT_CORNER(true), 
    UP_OR_DOWN(false), 
    LEFT_OR_RIGHT(false);


  private boolean corner;

  private R (boolean corner) {
    this.corner = corner;
  }
}

public class Ball {
  final float r;
  final boolean imag;
  final float constOfCorner;
  int doneAt;

  PVector pos, vel;
  private int hitcount;
  private boolean bouncedX, bouncedY, uw, lw, rw;

  ArrayList <PVector> dist = new ArrayList <PVector>();
  ArrayList <Block> block = new ArrayList <Block> ();

  boolean off;

  public Ball (PVector pos, PVector vel, float r, boolean imag, float d) {
    off = false;
    this.pos = pos;
    this.vel = vel;
    this.r = r;
    bouncedX = bouncedY = uw = lw = rw = true;
    constOfCorner = d;
    this.imag = imag;
    hitcount = 0;
  }

  // preparation for resolving the collision of a ball and blocks
  public void checkB(ArrayList <Block> B) {
    // if no collision detected, make the ball able to collide
    // the next time it hits an obstacle
    
    if (B == null) {
      bouncedX = false;
      bouncedY = false;
      return;
    }
    // record the collision's occurence
    dist.clear();
    block = B;

    // loop thru the blocks with which the ball has collided
    for (int i = 0; i < B.size(); i++) {

      // save the latest block in a temporary Block variable
      Block bl = B.get(i);

      // compute the distance between the ball and the block it hits
      // i.e. distance along the X axis and Y axis
      float Xd = pos.x - (bl.pos.x + bl.w / 2);
      float Yd = pos.y - (bl.pos.y + bl.w / 2);

      // this part increases the accuracy of later angle calculations
      float aXd = abs(Xd), aYd = abs(Yd);
      if (aXd - aYd > r) {
        if (aXd < bl.w/2) {
          Xd = Math.signum(Xd) * bl.w/2;
        }
      } else if (aYd - aXd > r) {
        if (aYd < bl.h/2) {
          Yd = Math.signum(Yd) * bl.h/2;
        }
      }
      // save the distance in the global list "dist"
      dist.add(new PVector(Xd, Yd));
    }
    // Decide where to move
    moveAfter();
  }



  // method that decides what to do if a collision took place
  public void moveAfter() {

    // the number of hits this frame
    int nHits = dist.size();
 
    
      
    // If three blocks were hit, which is very unlikely, but which is 
    // definitely possible, because our simulation is not fully accurate,
    // then it is an encapsulated from X and Y situation, so we just
    // flip the velocity signs and change the count on all three tiles

    if (nHits > 2) { 
        for (int i = 0; i < nHits; i++) 
          block.get(i).hitB(this);          
      xBoun(-1);
      yBoun(-1);
    } else {

      //THE DEFINER

      R[] gs = new R[nHits];
      for (int i = 0; i < nHits; i++) {
        float X = abs(dist.get(i).x), Y = abs(dist.get(i).y);

        // one of the corners is the case this time
        if (X + constOfCorner > block.get(i).w / 2 && 
          Y + constOfCorner > block.get(i).h / 2) {

          boolean XG = dist.get(i).x > 0, YG = dist.get(i).y > 0;


          // decide what corner the ball has hit depending
          // on its X and Y position relative to the
          // center of this Block

          if (XG && YG)  
            gs[i] = R.DOWN_RIGHT_CORNER; 
          if (!XG && !YG)  
            gs[i] = R.UP_LEFT_CORNER; 
          if (!XG && YG)  
            gs[i] = R.DOWN_LEFT_CORNER; 
          if (XG && !YG) 
            gs[i] = R.UP_RIGHT_CORNER;
        } else 

        // if corner is not the case, find out whether it 
        // is above/below or right/left off the Block

        if (X < Y) {
          gs[i] = R.UP_OR_DOWN;
        } else if (X > Y) {
          gs[i] = R.LEFT_OR_RIGHT;
        }
      }
      // if the ball hit two blocks, we have to check whether 
      // there are any corners and if there are, deal with them

      if (nHits > 1) {

        // Figuring out what to do if it's a corner case.
        // Draw a picture for each case, it'll be easier to understand.

        if (gs[1].corner && gs[0].corner) {
          block.get(1).hitB(this);
          block.get(0).hitB(this);

          //Seriously, try to draw it
          if (( gs[0] == R.UP_RIGHT_CORNER && gs[1] == R.UP_LEFT_CORNER  ) ||
            ( gs[0] == R.UP_LEFT_CORNER    && gs[1] == R.UP_RIGHT_CORNER ) ||
            ( gs[0] == R.DOWN_RIGHT_CORNER && gs[1] == R.DOWN_LEFT_CORNER  ) ||
            ( gs[0] == R.DOWN_LEFT_CORNER  && gs[1] == R.DOWN_RIGHT_CORNER  ) )

            yBoun(-1);

          else if (( gs[0] == R.UP_RIGHT_CORNER && gs[1] == R.DOWN_RIGHT_CORNER  ) ||
            ( gs[0] == R.UP_LEFT_CORNER    && gs[1] == R.DOWN_LEFT_CORNER ) ||
            ( gs[0] == R.DOWN_RIGHT_CORNER && gs[1] == R.UP_RIGHT_CORNER  ) ||
            ( gs[0] == R.DOWN_LEFT_CORNER  && gs[1] == R.UP_LEFT_CORNER  ) ) 

            xBoun(-1);

          else {
            // if somehow it's hit two corners that are near each other
            // but the blocks come from different sides
            yBoun(-1);
            xBoun(-1);
          }

          // if one of the hit parts is a corner but the other is not
        } else if (gs[0].corner && !gs[1].corner) {

          if (gs[1] == R.UP_OR_DOWN) {
            yBoun(1);
          }
          if (gs[1] == R.LEFT_OR_RIGHT) {
            xBoun(1);
          }
          // same stuff here
        } else if (!gs[0].corner && gs[1].corner) {

          if (gs[0] == R.UP_OR_DOWN) {
            yBoun(0);
          }
          if (gs[0] == R.LEFT_OR_RIGHT) {
            xBoun(0);
          }

          // every other case is just two block staying corner to corner
          // and the ball bouncing off their sides (off bottom/top of one
          // and left/right of the other)
        } else {
          yBoun(0);
          xBoun(1);
        }

        // this part implements if the ball collides with only one block
      } else {
        if (gs[0].corner) 
          // the most interesting case :)
          aBoun(0, gs[0]);
        else if (gs[0] == R.UP_OR_DOWN) 
          yBoun(0);
        else if (gs[0] == R.LEFT_OR_RIGHT) 
          xBoun(0);
      }
    }
  }


  // switching the ball's X speed 
  public void xBoun(int i) {
    if (!bouncedX) {
      vel.x *= -1;
      bouncedX = true;
    }
    // change the block's count if needed
    if (i != -1)
      block.get(i).hitB(this);
  }

  // switching the ball's Y speed
  public void yBoun(int i) {
    if (!bouncedY) {
      vel.y *= -1;
      bouncedY = true;
    }
    // change the block's count if needed
    if (i != -1)
      block.get(i).hitB(this);
  }

  // bounce the ball off a corner
  // it is the trickiest part
  public void aBoun(int i, R r) {
    if (!bouncedX && !bouncedY) {

      // change the block's count
        block.get(i).hitB(this);

      // determine the angle between Y component of the velocity 
      // vector and the vector itself
      float fth = atan2(abs(vel.y), abs(vel.x));

      /*
       * Giant Switch that prevents the bug where the ball hugs the corner
       * and changes its velocity vector in an unnatural way.
       * 
       * This bug manifests when the angle between the velocity vector and
       * the side of the block, against which it is bouncing, is too low.
       * 
       * The ball seeks to maintain this angle after the bounce and that
       * means that the angle between the "before" and "after" velocity
       * vectors is too big, precisely, more then 180 degrees.
       * 
       * So if the ball is headed at the upper right corner of the block and
       * approaches from the bottom-right of the block, it is going to bounce  
       * off the corner going in the left and up.
       *
       * This behaviour seems unnatural, because in real world it should 
       * bounce in the right in such case so we do just that right here.
       *
       * Try to disable this statement to better understand what is happening.
       */

      switch (r) {
      case UP_RIGHT_CORNER:
        if (vel.x < 0 && vel.y < 0) {
          if (fth > PI / 4) {
            xBoun(-1);
            return;
          }
        } else if (vel.x > 0 && vel.y > 0) {
          if (fth < PI / 4) {
            yBoun(-1);
            return;
          }
        } 
        break;

      case UP_LEFT_CORNER:
        if (vel.x < 0 && vel.y > 0) {
          if (fth < PI / 4) {
            yBoun(-1);
            return;
          }
        } else if (vel.x > 0 && vel.y < 0) {
          if (fth > PI / 4) {
            xBoun(-1);
            return;
          }
        } 
        break;

      case DOWN_LEFT_CORNER: 
        if (vel.x < 0 && vel.y < 0) {
          if (fth < PI / 4) {
            yBoun(-1);
            return;
          }
        } else if (vel.x > 0 && vel.y > 0) {
          if (fth > PI / 4) {
            xBoun(-1);
            return;
          }
        } 
        break;

      case DOWN_RIGHT_CORNER:
        if (vel.x < 0 && vel.y > 0) {
          if (fth > PI / 4) {
            xBoun(-1);
            return;
          }
        } else if (vel.x > 0 && vel.y < 0) {
          if (fth < PI / 4) {
            yBoun(-1);
            return;
          }
        } 
        break;
      }

      // record the bouncing-off
      bouncedX = bouncedY = true;

      // compute some values used to determine the angle of collision
      float X = abs(dist.get(i).x) - block.get(i).w / 2 + constOfCorner;
      float Y = abs(dist.get(i).y) - block.get(i).h / 2 + constOfCorner;

      // determining the angle
      float th = atan2(Y, X);
      //if (th > PI / 2) th = PI / 2;
      //if (th < 0) th = 0;

      // double angle is used later, so compute it
      float dth = th * 2;

      // temporary variable
      float temp = vel.x;

      // invoke the correct formula to find new velocity
      if (r == R.UP_RIGHT_CORNER || r == R.DOWN_LEFT_CORNER) {
        vel.x = -cos(dth) * vel.x + sin(dth) * vel.y;
        vel.y =  sin(dth) * temp + cos(dth) * vel.y;
      } else {
        vel.x = -cos(dth) * vel.x - sin(dth) * vel.y; 
        vel.y = -sin(dth) * temp + cos(dth) * vel.y;
      }
    }
  }

  public void move() {
    pos.add(vel);
  }

  public void show() {
    fill(255);
    if (!imag)
      ellipse(pos.x, pos.y, 2*r, 2*r);
    else {
      ellipse(pos.x, pos.y, 0.8 * r, 0.8 * r);
    }
  }

  public boolean done() {
    if (hitcount >= doneAt) return true;
    if (pos.y > height) return true;
    return false;
  }

  public void showStats() {
    println("X position " + pos.x);
    println("Y position " + pos.y);
    println("X velocity " + vel.x);
    println("Y velocity " + vel.y);
    println("Radius " + r);
    println("hitcount " + hitcount);
  }

  public void setDoneAt(int k) {
    doneAt = k;
  }

  public void upWall() {
    if (pos.y < r) {
      if (!uw) {
        uw = true;
        vel.y *= -1;
        hitcount++;
      }
    }
  }

  public void lWall() {
    if (pos.x < r) {
      if (!lw) {
        lw = true;
        vel.x *= -1;
        hitcount++;
      }
    } else lw = false;
  }

  public void rWall() {
    if (pos.x > width - r) {
      if (!rw) {
        rw = true;
        vel.x *= -1;
        hitcount++;
      }
    } else rw = false;
  }
}
