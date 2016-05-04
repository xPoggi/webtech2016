part of runner;

enum Direction {
  TOP,
  BOTTOM,
  LEFT,
  RIGHT
}

class Model {

  View v;
  Player p;

  Map<String, String> levels;
  Level currentLevel;
  String currentLevelName;
  bool running;
  bool won;
  bool inMenu;

  int visibleIndex;
  int playerPosX;
  int distance;
  int score;
  int points;

  List<Block> visibleBlocks;

  int viewport_x;
  int viewport_y;
  int speed;

  Model(int viewport_x, int viewport_y, int speed) {
    this.visibleBlocks = new List();
    this.levels = new Map<String, String>();

    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.speed = speed;

    this.won = false;
    this.inMenu = true;
    this.running = false;


    this.p = new Player();
  }

  void update(Timer t) {

    if (!this.running) {
      return;
    }

    getVisibleBlocks();

    this.p.update();
    this.visibleBlocks.forEach((b) => b.onUpdate());
    this.playerPosX += speed;
    detectCollisions();

    if (this.p.getPosY() < 0) {
      this.fail();
    }
    this.distance += 1; // tick = point
    this.score = this.distance + this.points;

    log("Tick");

  }

  void fail() {
    this.running = false;
    this.won = false;
  }

  void finish() {
    this.running = false;
    this.won = true;
  }

  void start() {
    this.p.reset();
    this.visibleIndex = 0;
    this.playerPosX = currentLevel.spawn.pos_x;
    this.p.pos_x = currentLevel.spawn.pos_x;
    this.p.pos_y = currentLevel.spawn.pos_y;
    this.visibleBlocks.clear();
    this.points = 0;
    this.distance = 0;
    this.running = true;
    this.inMenu = false;
  }

  void detectCollisions() {
    bool onGround = false;
    for (Block b in this.visibleBlocks) {
      if (b.canCollide) {
        if (playerCollision(b)) {
          Direction dir = collisionDirectionRewind(this.p, b);
          if (b.onCollision(this, this.p, dir)) {
            this.p.landed();
            this.p.pos_y = b.pos_y + b.size_y;
            onGround = true;
          }
        }
      }
    }
    if (!onGround) {
      this.p.fall();
    }
  }

  void jump() {
    log("Model: Jump");
    p.jump();
  }


  bool simpleRectCollision(int r1_pos_x, int r1_pos_y, int r1_size_x, int r1_size_y,
      int r2_pos_x, int r2_pos_y, int r2_size_x, int r2_size_y) {
    if ((r1_pos_x <= r2_pos_x + r2_size_x) &&
        (r1_pos_x + r1_size_x) >= r2_pos_x &&
        r1_pos_y <= (r2_pos_y + r2_size_y) &&
        (r1_size_y + r1_pos_y) >= r2_pos_y) {
      return true;
    } else {
      return false;
    }

  }


  //detect simple collisions between rectangles
  //source: https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
  bool playerCollision(Block rect) {
    return this.simpleRectCollision((this.p.pos_x+this.playerPosX), this.p.pos_y, this.p.size_x, this.p.size_y,
        rect.pos_x, rect.pos_y, rect.size_x, rect.size_y);
    return false;
  }

  Direction collisionDirectionRewind(Player player, Block rect) {
    final int rewindFactor = 5;

    //player sliding on the floor
    if (player.pos_y == (rect.pos_y + rect.size_y) && player.velocity_y == 0.0) {
      log("collisionDirectionRewind sliding");
      return Direction.TOP;
    }

    //rewind time to find collision
    int rewind_x = this.p.pos_x + this.playerPosX;
    int rewind_y = this.p.pos_y;
    int rewindCounter = 0;


    while(rewindCounter < rewindFactor) { // don't rewind past last event
      rewind_y -= ((this.p.velocity_y/rewindFactor).round()).toInt();
      if (!this.simpleRectCollision(rewind_x, rewind_y, this.p.size_x, this.p.size_y,
          rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
        return this.p.velocity_y <= 0 ? Direction.TOP : Direction.BOTTOM;
      }
      log("rewind_y $rewind_y");

      rewind_x -= (this.speed/rewindFactor).toInt();
      if (!this.simpleRectCollision(rewind_x, rewind_y, this.p.size_x, this.p.size_y,
          rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
        return Direction.LEFT;
      }
      log("rewind_x $rewind_x");

      rewindCounter++;
    }


    return Direction.RIGHT;

  }

  //https://gamedev.stackexchange.com/questions/29786/a-simple-2d-rectangle-collision-algorithm-that-also-determines-which-sides-that
  Direction collisionDirection(Player player, Block rect) {
    double w = 0.5 * (player.size_x + rect.size_x);
    double h = 0.5 * (player.size_y + rect.size_y);
    double dx = (player.centerX() + playerPosX) - rect.centerX();
    double dy = player.centerY() - rect.centerY();

    if (dx.abs() <= w && dy.abs() <= h) {
      /* collision! */
      double wy = w * dy;
      double hx = h * dx;

      if (wy > hx) {
        if (wy > -hx) {
          return Direction.TOP;
        } else {
          //TODO hack, clean me please
          if (player.pos_y >= (rect.pos_y + rect.size_y)) {
            return Direction.TOP;
          } else if ( (player.pos_y + player.size_y ) == rect.pos_y) {
            return Direction.BOTTOM;
          }
          return Direction.LEFT;
        }
      } else {
        if (wy > -hx) {
          //TODO hack, clean me please
          if (player.pos_y >= (rect.pos_y + rect.size_y)) {
            return Direction.TOP;
          } else if ( (player.pos_y + player.size_y ) == rect.pos_y) {
            return Direction.BOTTOM;
          }
          return Direction.RIGHT;
        } else {
          return Direction.BOTTOM;
        }
      }
    }
  }

  bool isBlockVisible(Block b) {
    if ((b.pos_x + b.size_x) > (playerPosX) && (b.pos_x) < (playerPosX + viewport_x)) {
      return true;
    }
    return false;
  }

  void getVisibleBlocks() {
    visibleBlocks.clear();

    //get all visible blocks, break when we reach invisible blocks
    for (Block b in currentLevel.blockList) {
      if (isBlockVisible(b)) {
        visibleBlocks.add(b);
      }
    }
  }

  void setLevel(String level) {
    currentLevel = new Level(level);
  }

  void setLevelList(String jsonString) {
    this.levels.clear();

    try {
      var jsonData = JSON.decode(jsonString);
      for (Map m in jsonData) {
        this.levels[m["name"]] = m["filename"];
      }
    } catch(e) {
      print(e);
    }

  }

  void mainMenu() {

    this.inMenu = true;

  }

}