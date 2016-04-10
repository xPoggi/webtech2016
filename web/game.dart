import 'dart:html';
import 'dart:async' show Timer;

const int tickRate = 16;

log(String msg) {
  if (const String.fromEnvironment('DEBUG') != null) {
    print('debug: $msg');
  }
}

class Player {
  DivElement playerElement;
  int height = 50;
  int width = 20;

  static double gravity = 0.8;
  double velocity_y = -gravity;
  double maxVelocity = 8.0;
  int y = 0;
  int x = 50;
  int speed = 5;

  bool jumping = false;
  bool grounded = true;

  Player(Game g) {
    this.y = this.height+10;
    this.jump();
    playerElement = new DivElement();
    playerElement.id = "player";
    playerElement.style.height = this.height.toString() + "px";
    playerElement.style.width = this.width.toString() + "px";

    g.gameElement.children.add(this.playerElement);
  }

  void jump() {
    if (!jumping && grounded) {
      jumping = true;
      grounded = false;
      velocity_y = speed * 2.0;
    }
  }

  void fall() {
    this.grounded = false;
  }

  void update() {
    if (!grounded) {
      print(velocity_y);
      this.y = (this.y + velocity_y).round();
      this.velocity_y -= gravity;
      if (this.velocity_y < -this.maxVelocity) { // don't accelerate to stupid falling speeds
        this.velocity_y = -this.maxVelocity;
      }
    }
  }

  int getPosY() {
    return y;
  }

  void landed() {
    this.velocity_y = 0.0;
    this.grounded = true;
    this.jumping = false;
  }
}

class Ground {

  DivElement groundElement;
  int height = 10;
  int width = 100;

  Game gameInstance;
  int x;
  int y;

  bool walkable = true;
  bool deadly = false;

  Ground(Game g) {
    this.gameInstance = g;
    groundElement = new DivElement();
    groundElement.className = "ground";
    groundElement.style.height = this.height.toString() + "px";
    groundElement.style.width = this.width.toString() + "px";

    g.gameElement.children.add(this.groundElement);

  }

  bool isWalkable() {
    return walkable;
  }

  bool isDeadly() {
    return deadly;
  }

  void setPosX(int x) {
    this.x = x;
  }

  void setPosY(int y) {
    this.y = y;
  }

  void update(int scrollspeed) {
    x = x - scrollspeed;
    if (this.x + this.width <= 0) {
      this.x = gameInstance.width - this.width;
    }
  }

  void contact() {

  }

}

class Game {

  int height = 330;
  int width  = 600;
  int scrollspeed = 5;
  DivElement gameElement;
  DivElement container;
  DivElement restart;
  Player player;
  List<Ground> grounds = new List<Ground>();
  Timer timer;

  Game() {
    this.container = querySelector('#container');

    this.gameElement = new DivElement();
    this.gameElement.id = "game";
    this.gameElement.style.height = this.height.toString() + "px";
    this.gameElement.style.width  = this.width.toString() + "px";

    this.container.children.add(this.gameElement);
    this.player = new Player(this);

    this.restart = new DivElement();
    this.restart.id = "restart";
    this.restart.text = "Start 'Game'";
    this.restart.style.position = "absolute";
    this.restart.style.bottom = ((this.height / 2) - 10).toString() + "px";
    this.restart.style.left = ((this.width / 2) - 60).toString() + "px";
    this.restart.style.backgroundColor = "red";
    this.gameElement.children.add(this.restart);

    Ground testGround = new Ground(this);
    testGround.setPosX(0);
    testGround.setPosY(0);
    Ground testGround2 = new Ground(this);
    testGround2.setPosX(100);
    testGround2.setPosY(0);
    Ground testGround3 = new Ground(this);
    testGround3.setPosX(200);
    testGround3.setPosY(0);
    Ground testGround4 = new Ground(this);
    testGround4.setPosX(350);
    testGround4.setPosY(10);
    Ground testGround5 = new Ground(this);
    testGround5.setPosX(420);
    testGround5.setPosY(0);
    Ground testGround6 = new Ground(this);
    testGround6.setPosX(520);
    testGround6.setPosY(0);

    grounds.add(testGround);
    grounds.add(testGround2);
    grounds.add(testGround3);
    grounds.add(testGround4);
    grounds.add(testGround5);
    grounds.add(testGround6);

    restart.onClick.listen(
        (event) => this.start());

//    this.start();

  }

  void start() {
    //begin the loop
    this.timer = new Timer.periodic(const Duration(milliseconds: tickRate), this.update);
    grounds[0].setPosX(0);
    grounds[1].setPosX(100);
    grounds[2].setPosX(200);
    grounds[3].setPosX(350);
    grounds[4].setPosX(420);
    grounds[5].setPosX(520);
    this.player.y = 50;
    this.restart.style.display = "none";
  }

  void stop() {
    this.timer.cancel();
    this.restart.style.display = "inline";
  }

  void update(Timer t) {

    this.player.update();
    for (var g in grounds) {
      g.update(scrollspeed);
    }

    redraw(this.player.playerElement, this.player.x, this.player.y);
    for (var g in grounds) {
      redraw(g.groundElement, g.x, g.y);
    }


    detectCollisions();
//    for (var g in grounds) {
//      g.groundElement.style.top = (this.convertToGameY(g.posy) - g.height).toString() + "px";
//      g.groundElement.style.left = g.posx.toString() + "px";
//    }

    if (this.player.y < 0) {
      this.stop();
    }
    print("Tick");

  }

  void redraw(DivElement e, x, y) {
    e.style.left = x.toString() + "px";
    e.style.bottom = y.toString() + "px";

  }

  void detectCollisions() {

    bool onGround = false;
    //check player collision with every object
    for (var g in grounds) {
      if (simpleCollision(this.player, g)) {
        print("Col");
        if (this.player.getPosY() >= g.y) {
          player.landed();
          player.y = g.y + g.height;
          g.contact();
          onGround = true;
          break;
        }
      }
    }

    if (!onGround) {
      this.player.fall();
    }

  }

  bool simpleCollision(rect1, rect2) {

    if (rect1.x <= (rect2.x + rect2.width) &&
        (rect1.x + rect1.width) >= rect2.x &&
        rect1.y <= (rect2.y + rect2.height) &&
        (rect1.height + rect1.y) >= rect2.y) {
      return true;
    } else {
      return false;
    }
  }

  int convertToGameY(int y) {
    return (this.height - y);
  }

}

void main() {

  Game game = new Game();

  window.onKeyDown.listen((KeyboardEvent ev) {
    switch (ev.keyCode) {
      case KeyCode.UP:    game.player.jump(); break;
      case KeyCode.SPACE: game.player.jump(); break;
    }
  });

  window.onTouchStart.listen((TouchEvent ev) {
    game.player.jump();
  });
}
