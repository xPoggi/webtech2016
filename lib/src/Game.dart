part of runner;

enum Quality { LOW, MEDIUM, HIGH }


// Controller
class Game {

  /// Constant defining game size
  static const int viewport_x = 600;
  static const int viewport_y = 330;

  /// Constant defining games horizontal speed
  static const int speed = 5;

  /// Constant of the relative path which stores the GameKey settings.
  static const gamekeySettings = 'gamekey.json';

  /// Defines the time between periodic GameKey availability checks
  static const gamekeyCheck = const Duration(seconds: 30);

  /// Stores model
  Model model;

  /// Stores controller
  View view;

  /// GameKey communicator used for storing highscores
  HighscoreGamekey gamekey;

  /// Timer used for periodic GameKey availability checks
  Timer gamekeyTrigger;

  bool limitFramerate;
  Quality quality;

  Storage localStorage;

  /// Creates Game instance
  /// Launches Main Menu
  Game() {

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

        this.gamekey.authenticate();

        // Check periodically if GameKey service is reachable. Display warning if not.
        this.gamekeyTrigger = new Timer.periodic(gamekeyCheck, (_) async {
          if (await this.gamekey.authenticate()) {
            this.view.statusMessage.text = '';
          } else {
            this.view.statusMessage.text = 'GK unavailable';
            print("Game: Game() Gamekey not connected");
          }
        });
      });
    } catch (error, stacktrace) {
      print ("Game: Game() Error: '$error'");
      print ("$stacktrace");
      this.view.statusMessage.text = 'GK Error';
    }


    // instantiate model and view
    this.model = new Model(viewport_x, viewport_y, speed);
    this.view = new View(viewport_x, viewport_y);


    // get local storage
    this.localStorage =  window.localStorage;

    // get stored quality setting
    this.quality = this.localStorage["quality"] == null ?
    Quality.MEDIUM :
    Quality.values[int.parse(this.localStorage["quality"])];

    this.view.updateQuality(this.quality);

    this.limitFramerate = this.localStorage["limit"] == "on" ? true : false;
    this.view.updateLimiter(this.limitFramerate);

    print(this.limitFramerate);

    // register keyboard input
    window.onKeyDown.listen((KeyboardEvent ev) async {
      switch (ev.keyCode) {
        case KeyCode.UP:    this.jump(); break;
        case KeyCode.SPACE: this.jump(); break;
        case KeyCode.ESC:     this.restartGame(); break;
      }
    });


    // register touchscreen input
    window.onTouchStart.listen((TouchEvent ev) async {
      this.jump();
    });

    window.onResize.listen((Event ev) {
      this.resizeGame();
    });

    // register click on restart button
    this.view.restartButtonRestart.onClick.listen(
        (event) => this.restartGame());


    // register click on return to main menu button
    this.view.restartButtonMenu.onClick.listen((event) => this.mainMenu());

    // register click on start button in main menu
    this.view.menuButtonStart.onClick.listen((event) {

      String level = this.view.menuLevelSelect.selectedOptions[0].value;
      this.startGame(level);

    });

    this.view.menuButtonLimiter.onClick.listen((event) {
      if (this.limitFramerate) {
        this.limitFramerate = false;
        this.localStorage["limit"] = "off";
      } else {
        this.limitFramerate = true;
        this.localStorage["limit"] = "on";
      }
      this.view.updateLimiter(this.limitFramerate);
    });

    this.view.menuButtonQuality.onClick.listen((event) {
      switch (this.quality) {
        case Quality.HIGH:
          this.quality = Quality.LOW;
          this.localStorage["quality"] = Quality.LOW.index.toString();
          break;
        case Quality.MEDIUM:
          this.quality = Quality.HIGH;
          this.localStorage["quality"] = Quality.HIGH.index.toString();
          break;
        case Quality.LOW:
          this.quality = Quality.MEDIUM;
          this.localStorage["quality"] = Quality.MEDIUM.index.toString();
          break;

      }
      this.view.updateQuality(this.quality);
    });


    // register click on submit highscore button
    this.view.restartButtonSubmit.onClick.listen((event) => this.showLogin());

    // register click on login button
    this.view.restartLoginSubmit.onClick.listen((event) => this.submitScore());

    this.resizeGame();

  }

  void resizeGame() {
    int win_x = window.innerWidth;
    int win_y = window.innerHeight;

    this.view.rescale(win_x, win_y);
  }

  /// Retrieves Level
  ///
  /// Returns the Level for [levelName] in JSON format
  Future<String> getLevel(String levelName) async {
    var level = "levels/" + levelName;

    return await HttpRequest.getString(level).asStream().join();
  }

  /// Jumps.
  ///
  /// Performs the jump action for the current game state
  jump() async {
    if (model.state == State.WON || model.state == State.FAIL) {
//      this.restartGame();
    } else {
      this.model.jump();
    }
  }

  void skipUpdate(int num) {
    this.view.update(this.model);
    window.animationFrame.then(this.update);
  }

  /// Updates the game
  ///
  /// Updates the model and view due to Timer [t] call
  void update(int num) {
    log("Game: update()");
    if (this.model.state == State.RUNNING) {
      log("Game: update() - running");

      this.model.update();
      if (this.limitFramerate) {
        this.model.update();
        window.animationFrame.then(this.skipUpdate);
      } else {
        this.view.update(this.model);
        window.animationFrame.then(this.update);
      }
    } else {
      this.setHighscores();

      this.view.update(this.model);
    }
  }

  /// Retrieves TOP 10 highscore from Gamekey service.
  ///
  /// Returns List of up to 10 highscore entries. { 'name': STRING, 'created': STRING, 'score': INT }
  /// Returns [] if gamekey service is not available.
  /// Returns [] if no highscores are present.
  Future<List<Map>> getHighscores() async {
    var scores = [];
    var levels;
    try {
      final states = await gamekey.getStates();

      levels = states.map((entry) => {
        'username' : "${entry['username']}",
        'date' : "${entry['created']}",
        'scores' : entry['state']['scores']
      });

      scores = levels.where((entry) => (entry["scores"]["${this.model.currentLevelHash}"] != null)).map((entry) => {
        'name' : "${entry['username']}",
        'date' : "${entry['date']}",
        'score' : entry["scores"]["${this.model.currentLevelHash}"]
      }).toList();

      scores.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      scores.sort((a, b) => b['score'] - a['score']);
    } catch (error, stacktrace) {
      print("Game: getHighscores() Error: ${error}");
      print(stacktrace);
    }
    return scores.take(10);
  }

  /// Stores current score as highscore
  ///
  /// Stores the current score as a highscore for the user and password in the view.
  storeHighscore() async {
    String user = view.restartLoginUser.value;
    String pwd  = view.restartLoginPassword.value;

    if (user.length == 0) {
      return;
    }

    String id = await gamekey.getUserId(user);
    // create new user and store
    if (id == null) {
      final usr = await gamekey.registerUser(user, pwd);
      if (usr == null) {
        return;
      }
      final stored = await gamekey.storeState(usr['id'], {
        "scores": {
          "${this.model.currentLevelHash}" : this.model.score
        },
        'version': '0.0.1'
      });
      if (stored) {
        this.view.hideHighscoreLogin();
        this.setHighscores();
        return;
      } else {
        view.statusMessage.text = "Error";
        return;
      }
    }

    // retrieve user and store
    if (id != null) {
      final user = await gamekey.getUser(id, pwd);

      if (user == null) {
        return;
      }

      final stored = await gamekey.storeState(user['id'], {
        "scores": {
          "${this.model.currentLevelHash}" : this.model.score
        },
        'version': '0.0.1'
      });
      if (stored) {
        this.view.hideHighscoreLogin();
        this.setHighscores();
        return;
      } else {
        view.statusMessage.text = "Error";
        return;
      }
    }
  }

  /// Causes score to be stored and returns the user to main menu
  submitScore() async {
    this.storeHighscore();
    this.view.hideHighscoreSubmit();

    this.model.highscores = await getHighscores();
    this.view.update(this.model); // update as soon as we have scores
  }

  /// Shows the login mask
  void showLogin() {
    this.view.showHighscoreLogin();
  }

  /// Updates the highscores for the current level
  setHighscores() async {

    this.model.highscores =  await getHighscores();
    this.view.update(this.model); // update as soon as we have scores

  }

  /// Restarts the current level
  ///
  /// Very hacky way to restart the game
  restartGame() async {
    if (this.model.state != State.MENU) {
      this.model.fail();
      this.update(0);

      // wait 10ms to make sure the Futures have completed...
      await new Future.delayed(const Duration(milliseconds: 10), () => "1");
      startGame(this.model.currentLevelName);
    }
  }

  /// Starts the game.
  ///
  /// Starts the game on the given [level]
  startGame(String level) async {

    await getLevel(level).then((levelJson) => this.model.setLevel(levelJson));
    this.model.currentLevelName = level;

    this.model.start();
    this.view.onStart(this.model);
    this.view.update(this.model);

    window.animationFrame.then(this.update);
  }

  /// Opens the main menu
  ///
  /// Opens the main menu and updates the list of available levels
  mainMenu() async {

    var levels = "levels/levels.json";

    var request = await HttpRequest.getString(levels).asStream().join();

    this.model.setLevelList(request);
    this.model.mainMenu();

    this.view.update(this.model);


  }
}