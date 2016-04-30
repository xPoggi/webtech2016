import 'Level.dart';
import 'dart:async';
import 'Player.dart';
import 'View.dart';
import 'blocks/Block.dart';

enum Direction {
  TOP,
  BOTTOM,
  LEFT,
  RIGHT
}

class Model {

  View v;

  bool running;
  Level currentLevel;
  Player p;

  int visibleIndex;
  int playerPosX;
  List<Block> visibleBlocks;

  int viewport_x;
  int viewport_y;
  int speed;

  Model(int viewport_x, int viewport_y, int speed) {
    this.visibleBlocks = new List();

    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.speed = speed;

    this.p = new Player();
  }

  void update(Timer t) {

    if (!this.running) {
      return;
    }

    getVisibleBlocks();

    this.p.update();

    this.playerPosX += speed;

    detectCollisions();

    if (this.p.getPosY() < 0) {
      this.fail();
    }

    print("Tick");
    print(this.visibleBlocks);

  }

  void fail() {
    this.running = false;
  }

  void start() {
    this.p.reset();
    this.visibleIndex = 0;
    this.playerPosX = 50;
    this.visibleBlocks.clear();
    this.running = true;
  }

  void detectCollisions() {
    try {
      bool onGround = false;
      for (Block b in this.visibleBlocks) {
        if (b.canCollide) {
          if (simpleCollision(this.p, b)) {
            if (this.p.getPosY() >= b.pos_y) {
              this.p.landed();
              this.p.pos_y = b.pos_y + b.size_y;
              b.onCollision(Direction.TOP);
              onGround = true;
              break;
            }
          }
        }
      }
      if (!onGround) {
        this.p.fall();
      }

    } catch(e, ex) {
      print(e);
      print(ex);
    }

  }

  void jump() {
    p.jump();
  }

  //detect simple collisions between rectangles
  //source: https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
  bool simpleCollision(player, rect) {
    if ((player.pos_x + this.playerPosX) <= (rect.pos_x + rect.size_x) &&
        ((player.pos_x + this.playerPosX) + player.size_x) >= rect.pos_x &&
        player.pos_y <= (rect.pos_y + rect.size_y) &&
        (player.size_y + player.pos_y) >= rect.pos_y) {
      return true;
    } else {
      return false;
    }
  }

  Direction collisionDirection(player, rect) {
    //TODO
    return Direction.TOP;
  }

  bool isBlockVisible(Block b) {
    if ((b.pos_x + b.size_x) > (playerPosX) && (b.pos_x) < (playerPosX + viewport_x)) {
      return true;
    }
  }

  void getVisibleBlocks() {
    visibleBlocks.clear();
    //track if we've set visibleIndex to a new value
    bool visibleSet = false;
    //get all visible blocks, break when we reach invisible blocks
    for (int i = visibleIndex; i < currentLevel.blockList.length; i++) {
      Block b = currentLevel.blockList[i];

      if (isBlockVisible(currentLevel.blockList[i])) {
        visibleBlocks.add(b);
        if (!visibleSet) {
          visibleIndex = i;
          visibleSet = true;
        }
      } else if (visibleBlocks.length > 0) {
        // we've passed the visible blocks, break
        break;
      }
    }
  }

  void setLevel(String level) {
    currentLevel = new Level(level);
  }

}