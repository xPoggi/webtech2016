part of runner;

enum Direction {
  TOP,
  BOTTOM,
  LEFT,
  RIGHT
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
  int currentLevelHash;

  /// Highscores for current level
  List<Map<String, String>> highscores;


  //TODO unify states

  /// running state
  bool running;

  /// level finished state
  bool won;

  /// In main menu state
  bool inMenu;

  int visibleIndex;

  /// Player level position
//  int playerPosX;

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
    this.visibleBlocks = new List();
    this.levels = new Map<String, String>();
    this.highscores = new List<Map<String, String>>();

    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.speed = speed;

    this.won = false;
    this.inMenu = true;
    this.running = false;


    this.player = new Player();
  }

  /// Updates the model
  ///
  /// Updates the position of every object, detects collisions and increases score
  void update(Timer t) {

    if (!this.running) {
      return;
    }

    getVisibleBlocks();

    this.player.update();

    this.visibleBlocks.forEach((b) => b.onUpdate());
//    this.player.pos_x = this.player.pos_x + speed;
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
    this.running = false;
    this.won = false;
  }

  /// Sets game to won state
  void finish() {
    this.running = false;
    this.won = true;
  }


  /// Sets game to running state on current level
  void start() {
    this.player.reset();
    this.visibleIndex = 0;
//    this.playerPosX = currentLevel.spawn.pos_x;
    this.player.pos_x = currentLevel.spawn.pos_x;
    this.player.pos_y = currentLevel.spawn.pos_y;
    this.visibleBlocks.clear();
    this.points = 0;
    this.distance = 0;
    this.running = true;
    this.inMenu = false;
  }

  /// Detects players collision with objects
  ///
  /// Detects the players collision with objects in the game world.
  /// The first detection uses [simpleRectCollision] to detect a collision,
  /// the second detection uses [collisionDirectionRewind] to find its direction
  void detectCollisions() {
    bool onGround = false;
    for (Block b in this.visibleBlocks) {
      if (b.canCollide) {
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

      rewind_x -= (this.speed/rewindFactor).toInt();
      if (!this.simpleRectCollision(rewind_x, rewind_y, this.player.size_x, this.player.size_y,
          rect.pos_x, rect.pos_y, rect.size_x, rect.size_y)) {
        return Direction.LEFT;
      }
      log("Model: collisionDirectionRewind() rewind_x $rewind_x");

      rewindCounter++;
    }


    return Direction.RIGHT;

  }


  /// Calculates if [b] is within viewport
  bool isBlockVisible(Block b) {
    if ((b.pos_x + b.size_x) > (this.player.pos_x - Player.player_offset) && (b.pos_x) < ((this.player.pos_x - Player.player_offset) + viewport_x)) {
      return true;
    }
    return false;
  }

  /// Sets [visibleBlocks] to currently visible Blocks
  void getVisibleBlocks() {
    visibleBlocks.clear();

    //get all visible blocks, break when we reach invisible blocks
    for (Block b in currentLevel.blockList) {
      if (isBlockVisible(b)) {
        visibleBlocks.add(b);
      }
    }
  }

  /// Hashes Strings based on number theory
  int hash(String s) {
    int hashval = 0;
    int HASHSIZE = 100001;

    s.runes.forEach((char) {
      hashval = char + 31 * hashval;
    });

    print(hashval % HASHSIZE);
    return hashval % HASHSIZE;
  }

  /// Sets [currentLevel] to JSON [level]
  void setLevel(String level) {
    this.currentLevel = new Level(level);
    this.currentLevelHash = hash(level);
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

    this.inMenu = true;

  }

}