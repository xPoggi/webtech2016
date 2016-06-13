part of runner;

enum Direction {
  TOP,
  BOTTOM,
  LEFT,
  RIGHT
}

enum State {
  MENU,
  RUNNING,
  WON,
  FAIL
}

class Model {


  /// Player instance
  Player player;

  /// List of levels
  Map<String, String> levels;

  /// Currently loaded level state
  Level currentLevel;

  /// Currently loaded level name
  String currentLevelName;

  /// Current level hash
  String currentLevelHash;

  /// Highscores for current level
  List<Map<String, String>> highscores;

  /// running state
  State state;

  /// First visible block index
  int visibleIndex;

  int distance;
  int score;
  int points;

  /// List of Blocks currently in viewport
  List<Block> visibleBlocks;

  /// Viewport
  int viewport_x;
  int viewport_y;

  /// Horizontal speed
  int speed;

  /// Creates Model instance
  Model(int viewport_x, int viewport_y, int speed) {
    this.visibleBlocks = new List<Block>(20);
    this.levels = new Map<String, String>();
    this.highscores = new List<Map<String, String>>();

    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.speed = speed;

    this.state = State.MENU;

    this.player = new Player();
  }

  /// Updates the model
  ///
  /// Updates the position of every object, detects collisions and increases score
  void update() {

    if (this.state != State.RUNNING) {
      return;
    }

    getVisibleBlocks();

    this.player.update();

    this.visibleBlocks.where((b) => b != null).forEach((b) => b.onUpdate());
    this.player.pos_x = this.player.pos_x + this.speed;
    detectCollisions();

    if (this.player.getPosY() < 0) {
      this.fail();
    }
    this.distance += 1; // tick = point
    this.score = this.distance + this.points;

    log("Model: update() tick");

  }

  /// Sets game to fail state
  void fail() {
    this.state = State.FAIL;
  }

  /// Sets game to won state
  void finish() {
    this.state = State.WON;
  }

  /// Sets game to running state on current level
  void start() {
    this.player.reset();
    this.resetVisibleIndex();
    this.clearVisibleBlocks();
    this.player.pos_x = currentLevel.spawn.pos_x;
    this.player.pos_y = currentLevel.spawn.pos_y;
    this.points = 0;
    this.distance = 0;
    this.state = State.RUNNING;
  }

  /// Detects players collision with objects
  ///
  /// Detects the players collision with objects in the game world.
  /// The first detection uses [simpleRectCollision] to detect a collision,
  /// the second detection uses [collisionDirectionRewind] to find its direction
  void detectCollisions() {
    bool onGround = false;
    for (Block b in this.visibleBlocks) {
      if (b != null && b.canCollide) {
        if (playerCollision(b)) {
          Direction dir = collisionDirectionRewind(this.player, b);
          if (b.onCollision(this, this.player, dir)) {
            this.player.landed();
            this.player.pos_y = b.pos_y + b.size_y;
            onGround = true;
          }
        }
      }
    }
    if (!onGround) {
      this.player.fall();
    }
  }

  /// Makes player jump
  void jump() {
    log("Model: jump()");
    this.player.jump();
  }

  /// Detects collisions between rectangles
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


  /// Detects collision between [Player] and given [Block]
  bool playerCollision(Block rect) {
    return this.simpleRectCollision((this.player.pos_x), this.player.pos_y, this.player.size_x, this.player.size_y,
        rect.pos_x, rect.pos_y, rect.size_x, rect.size_y);
  }

  /// Detects collision direction
  ///
  /// Detects collision direction by rewinding the last tick in steps of 1/5.
  /// Splits the rewind into horizontal and vertical steps.
  /// If moving the player back on the y axis stopped the collision, the player collided from either
  /// [Direction.TOP] or [Direction.BOTTOM], depending on [Player.velocity_y]
  /// Similar, if moving the player back on the x axis stopped the collision,
  /// the player collided from either [Direction.LEFT] or [Direction.RIGHT].
  /// Returns [Direction]
  Direction collisionDirectionRewind(Player player, Block rect) {
    final int rewindFactor = 5;

    //player sliding on the floor
    if (player.pos_y == (rect.pos_y + rect.size_y) && player.velocity_y == 0.0) {
      log("Model: collisionDirectionRewind() player sliding");
      return Direction.TOP;
    }

    //rewind time to find collision
    int rewind_x = this.player.pos_x;
    int rewind_y = this.player.pos_y;
    int rewindCounter = 0;


    while(rewindCounter < rewindFactor) { // don't rewind past last event
      rewind_y -= ((this.player.velocity_y/rewindFactor).round()).toInt();
      if (!this.simpleRectCollision(rewind_x, rewind_y, this.player.size_x, this.player.size_y,
          rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
        return this.player.velocity_y <= 0 ? Direction.TOP : Direction.BOTTOM;
      }
      log("Model: collisionDirectionRewind() rewind_y $rewind_y");

      rewind_x -= this.speed ~/ rewindFactor;
      if (!this.simpleRectCollision(rewind_x, rewind_y, this.player.size_x, this.player.size_y,
          rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
        return Direction.LEFT;
      }
      log("Model: collisionDirectionRewind() rewind_x $rewind_x");

      rewindCounter++;
    }

    // well this isn't elegant...
    rewind_y -= ((this.player.velocity_y).ceil()).toInt();
    if (!this.simpleRectCollision(rewind_x, rewind_y, this.player.size_x, this.player.size_y,
        rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
      return this.player.velocity_y <= 0 ? Direction.TOP : Direction.BOTTOM;
    }
    log("Model: collisionDirectionRewind() rewind_y $rewind_y - LAST RESORT!");

    // insane default
    return Direction.RIGHT;

  }

  void clearVisibleBlocks() {
    for (int i = 0; i < this.visibleBlocks.length; i++) {
      this.visibleBlocks[i] = null;
    }
  }

  void addToVisibleBlocks(Block b) {
    for (int i = 0; i < this.visibleBlocks.length; i++) {
      if (this.visibleBlocks[i] == null) {
        this.visibleBlocks[i] = b;
        break;
      }
    }
  }

  /// Calculates if [b] is within viewport
  bool isBlockVisible(Block b) {
    if (((b.pos_x + b.size_x) > (this.player.pos_x - Player.player_offset) && (b.pos_x) < ((this.player.pos_x - Player.player_offset) + viewport_x)) && b.isVisible) {
      return true;
    }
    return false;
  }

  void resetVisibleIndex() {
    this.visibleIndex = 0;
  }

  /// Sets [visibleBlocks] to currently visible Blocks
  void getVisibleBlocks() {
    this.clearVisibleBlocks();
    bool visibleSet = false;
    int countFails = 0;
    const int upperTolerance = 10;
    const int lowerTolerance = 5;
    //get all visible blocks, break when we reach invisible blocks
    for (int i = this.visibleIndex; i < currentLevel.blockList_static.length; i++) {
      Block b = currentLevel.blockList_static[i];
      if (isBlockVisible(b)) {
        this.addToVisibleBlocks(b);
        if (!visibleSet) {
          this.visibleIndex = i - lowerTolerance;
          visibleSet = true;
          countFails = 0;
          if ( this.visibleIndex.isNegative ) {
            this.visibleIndex = 0;
            continue;
          }
        }
      } else if (visibleBlocks.length > 0 && countFails >= upperTolerance) {
        // we've most likely passed the visible blocks, break
        log("Model: getVisibleBlocks() breaking after ${countFails} misses");
        break;
      } else {
        countFails++;
      }
    }
    for (Block b in currentLevel.blockList_dynamic) {
      if (isBlockVisible(b)) {
        this.addToVisibleBlocks(b);
      }
    }
    log(visibleBlocks.toString());
  }

  /// Hashes Strings based on number theory
  String hash(String s) {
    List<int> bytes = UTF8.encode(s);

    return sha256.convert(bytes).toString();
  }

  /// Sets [currentLevel] to JSON [level]
  void setLevel(String level) {
    this.currentLevel = new Level(level);
    this.currentLevelHash = hash(level);
    this.speed = currentLevel.speed ?? 5;
  }

  /// Sets [levels] to levels listed in [jsonString]
  void setLevelList(String jsonString) {
    this.levels.clear();

    try {
      var jsonData = JSON.decode(jsonString);
      for (Map m in jsonData) {
        this.levels[m["name"]] = m["filename"];
      }
    } catch(error, stacktrace) {
      print("Model: setLevelList() Error: ${error}");
      print(stacktrace);
    }

  }

  /// Sets game state to main menu
  void mainMenu() {

    this.state = State.MENU;

  }

}