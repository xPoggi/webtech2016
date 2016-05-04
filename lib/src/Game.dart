part of runner;

// Controller
class Game {

  static const int viewport_x = 600;
  static const int viewport_y = 330;
  static const int tickrate = 16;
  static const int speed = 5;

  /**
   * Constant of the relative path which stores the gamekey settings.
   */
  static const gamekeyCheck = const Duration(seconds: 30);
  static const gamekeySettings = 'gamekey.json';

  Model model;
  View view;
  Timer timer;

  HighscoreGamekey gamekey;
  Timer gamekeyTrigger;

  Game() {


    //TODO Why the fuck would this run twice and spawn two games?
    //And WHY would this only happen when simulation a mobile device using chrome?!
    //this is stupid
    if (querySelector("#game") != null) {
      return;
    }

    try {
      // Download gamekey settings. Display warning on problems.
      HttpRequest.getString(gamekeySettings).then((json) {
        final settings = JSON.decode(json);

        // Create gamekey client using connection parameters
        this.gamekey = new HighscoreGamekey(
            settings['host'],
            settings['port'],
            settings['id'],
            settings['secret'] //TODO la di da,
        );

        // Check periodically if gamekey service is reachable. Display warning if not.
        this.gamekeyTrigger = new Timer.periodic(gamekeyCheck, (_) async {
          if (await this.gamekey.authenticate()) {
            this.view.statusMessage.text = 'GK Connected';
            print("Gamekey connected");
          } else {
            this.view.statusMessage.text = 'GK Disconnected';
            print("Gamekey not connected");
          }
        });
      });
    } catch (error, stacktrace) {
      print ("Game() caused following error: '$error'");
      print ("$stacktrace");
      this.view.statusMessage.text = 'GK Error';
    }


    this.model = new Model(viewport_x, viewport_y, speed);
    this.view = new View(viewport_x, viewport_y);

    window.onKeyDown.listen((KeyboardEvent ev) async {
      switch (ev.keyCode) {
        case KeyCode.UP:    this.jump(); break;
        case KeyCode.SPACE: this.jump(); break;
      }
    });

    window.onTouchEnd.listen((TouchEvent ev) async {
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
    var level = currentLocation.toString().replaceAll("index.html", "") + "levels/" + levelName;

    return await HttpRequest.getString(level).asStream().join();
  }

  jump() async {
    if (!this.model.running && !this.model.inMenu) {
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

      if (this.model.won) {
        this.showScore();
      }

      this.view.update(this.model);
    }
  }

  void showScore() {

  }

  void restartGame() {
    this.model.p.reset();
    startGame(this.model.currentLevelName);
  }

  startGame(String level) async {

    await getLevel(level).then((levelJson) => this.model.setLevel(levelJson));
    this.model.currentLevelName = level;

    this.model.start();
    this.view.onStart();
    this.view.update(this.model);
    if (this.timer != null) {
      this.timer.cancel();
    }

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

//  Game g = new Game();
//
//  g.startGame();

}