part of runner;

// Controller
class Game {

  static const int viewport_x = 600;
  static const int viewport_y = 330;
  static const int tickrate = 16;
  static const int speed = 5;

  Model model;
  View view;
  Timer timer;

  Game() {

    this.model = new Model(viewport_x, viewport_y, speed);
    this.view = new View(viewport_x, viewport_y);

    window.onKeyDown.listen((KeyboardEvent ev) async {
      switch (ev.keyCode) {
        case KeyCode.UP:    this.jump(); break;
        case KeyCode.SPACE: this.jump(); break;
      }
    });

    window.onTouchStart.listen((TouchEvent ev) async {
      this.jump();
    });

    view.restart.onClick.listen(
        (event) => this.restartGame());

    view.restartMenu.onClick.listen((event) => this.mainMenu());

    view.menu.onClick.listen((event) {

      String level = view.menuLevelSelect.selectedOptions[0].value;
      print(level);
      this.startGame(level);

    });

  }

  Future<String> getLevel(String levelName) async {
    var currentLocation = window.location;
    var level1 = currentLocation.toString().replaceAll("index.html", "") + "levels/" + levelName;

    return await HttpRequest.getString(level1).asStream().join();

  }

  jump() async {
    if (!this.model.running && !this.model.inMenu) {
      if (this.timer != null) {
        this.timer.cancel();
      }
      this.restartGame();
    } else {
      this.model.jump();
    }
  }

  void update(Timer t) {
    if (this.model.running) {
      this.model.update(t);
      this.view.update(this.model);
    } else {
      this.timer.cancel();
      this.view.update(this.model);
    }
  }

  void restartGame() {

    startGame(this.model.currentLevelName);

  }

  startGame(String level) async {

    await getLevel(level).then((levelJson) => this.model.setLevel(levelJson));
    this.model.currentLevelName = level;

    this.model.start();
    this.view.onStart();
    this.view.update(this.model);
    this.timer = new Timer.periodic(const Duration(milliseconds: tickrate), this.update);

  }

  mainMenu() async {

    var currentLocation = window.location;
    var levels = currentLocation.toString().replaceAll("index.html", "") + "levels/levels.json";

    var request = await HttpRequest.getString(levels).asStream().join();

    this.model.setLevelList(request);
    this.model.mainMenu();

    this.view.update(this.model);


  }
}

void main() {

  Game g = new Game();

//  g.startGame();

}