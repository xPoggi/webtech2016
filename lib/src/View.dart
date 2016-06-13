part of runner;

class View {


  /// game containers
  DivElement container;
  DivElement gameElement;

  /// Restart overlay container
  DivElement restartOverlay;
  DivElement restartMessage;

  /// Restart clickables container
  DivElement restartContainer;
  DivElement restartButtonRestart;
  DivElement restartButtonSubmit;
  DivElement restartButtonMenu;

  /// Restart highscore list container
  DivElement restartHighscoreContainer;
  UListElement restartHighscoreList;

  /// Restart login container
  DivElement restartLogin;
  InputElement restartLoginUser;
  InputElement restartLoginPassword;
  DivElement restartLoginSubmit;


  /// Main menu overlay container
  DivElement menuOverlay;
  DivElement menuTitle;

  /// Menu clickables container
  DivElement menuContainer;
  DivElement menuButtonStart;
  SelectElement menuLevelSelect;
  DivElement menuButtonLimiter;
  DivElement menuButtonQuality;

  /// Score Element
  DivElement score;
  DivElement statusMessage;

  /// Game Size
  int viewport_x;
  int viewport_y;

  /// Storage for divs, avoids creating divs all the time
  List<DivElement> divs;

  /// Player element
  DivElement player;

  /// Map of used divs by id
  Map<int, DivElement> usedDivs;

  /// Map for current quality class settings
  Map<String, String> qualityClass;


  /// Creates View instance
  ///
  /// Creates the instance for View and adds all the necessary game elements to the DOM
  View(int viewport_x, int viewport_y) {
    log("View: View() instance created");
    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.divs = new List<DivElement>(20);

    // create 20 divs and store them for use, avoid expensive creation while running
    for (int i = 0; i < 20; i++) {
      divs[i] = new DivElement();
    }



    this.usedDivs = new Map<int, DivElement>();

    this.qualityClass = new Map<String, String>();

    this.container = querySelector('#container');

    this.gameElement = querySelector('#game');
    this.gameElement.style.width  = "${this.viewport_x}px";
    this.gameElement.style.height = "${this.viewport_y}px";

    for (DivElement d in divs) {
      this.gameElement.children.add(d);
      d.style.display = "none";
      d.dataset["id"] = "none";
    }

    this.player = new DivElement();
    this.player.id = "Player";
    this.player.className = "Player block";
    this.player.style.display = "block";
    this.gameElement.children.add(this.player);


    this.restartOverlay = querySelector('#restart-overlay');
    this.restartHighscoreContainer = querySelector('#restart-overlay-highscores');
    this.restartHighscoreList = querySelector('#restart-overlay-highscores-list');

    this.restartContainer = querySelector('#restart-overlay-button-container');
    this.restartButtonRestart = querySelector("#restart-overlay-button-restart");
    this.restartButtonSubmit = querySelector('#restart-overlay-button-highscore');
    this.restartButtonMenu = querySelector('#restart-overlay-button-menu');


    this.restartLogin = querySelector('#restart-overlay-login');
    this.restartLoginUser = querySelector("#restart-overlay-login-user");
    this.restartLoginPassword = querySelector("#restart-overlay-login-password");
    this.restartLoginSubmit = querySelector("#restart-overlay-login-submit");

    this.restartMessage = querySelector('#restart-overlay-message');

    this.score = querySelector("#score");

    this.statusMessage = querySelector('#status-message');

    this.menuOverlay = querySelector("#menu-overlay");
    this.menuTitle = querySelector("#menu-overlay-title");

    this.menuContainer = querySelector("#menu-overlay-button-container");
    this.menuButtonStart = querySelector("#menu-overlay-button-start");
    this.menuLevelSelect = querySelector("#menu-overlay-level-select");
    this.menuButtonLimiter = querySelector("#menu-overlay-button-limiter");
    this.menuButtonQuality = querySelector("#menu-overlay-button-quality");

    this.menuButtonStart.text = "Start";
    this.menuButtonLimiter.text = "30fps - ✕";
    this.menuButtonQuality.text = "Quality: Bad";

    this.restartButtonRestart.text = "Restart";
    this.restartButtonSubmit.text = "Submit Highscore";
    this.restartButtonMenu.text = "Return to Menu";
    this.restartLoginSubmit.text = "Submit";

    this.preloadImages();

  }

  /// Preloads textures to avoid pop-in
  void preloadImages() {
    List<String> classList = ["Bullet", "Cobble", "Coin", "Finish", "Ground", "Guy", "SpikesBottom", "SpikesTop", "Wall"];

    for (int i = 0; i < classList.length; i++) {
      divs[i].className = classList[i];
      // show element for just a moment, thanks firefox...
      divs[i].style.display = "block";
      divs[i].style.display = "none";
    }

  }


  /// Scales View based on window size
  void rescale(int x, int y) {
    double scale;
    int vx = this.viewport_x + 10; // add border for calculation
    int vy = this.viewport_y + 10;
    scale = (x/vx) < (y/vy) ? (x/vx) : y/vy;
    document.body.style.transform = "scale(${scale})";
  }

  /// Updates the View based on [Model]
  void update(Model m) {
    log("View update()");
    if (m.state == State.RUNNING) {
      log("View update()  - running");
      updateGame(m);
    } else if (m.state == State.MENU) {
      log("View update() - inMenu");
      showMenu(m);
    } else { // fail/won
      log("View update() - endscreen");
      onStop(m);
    }
  }

  void drawBlocks(Model model) {
    for (int i = 0; i < model.visibleBlocks.length; i++) {
      Block b = model.visibleBlocks[i];
      DivElement d = this.divs[i];
      if (b == null && d.style.display != "none") {
        d.style.display = "none";
        d.dataset["id"] = "none";
      } else if (b != null && ( (d.style.display == "none") || (d.dataset["id"] != b.id.toString()) )) {
        d.style.display = "block";
        d.className = this.qualityClass[b.name];
        d.dataset["id"] = b.id.toString();
        if (b.name == "Message") {
          d.text = (b as Message).message;
        } else {
          d.text = "";
        }

        d.style.width = "${b.size_x}px";
        d.style.height = "${b.size_y}px";

        d.style.left = "${b.pos_x  - model.player.pos_x + Player.player_offset}px";
        d.style.bottom = "${b.pos_y}px";
      } else if (b != null) {
        d.style.left = "${b.pos_x  - model.player.pos_x + Player.player_offset}px";
        d.style.bottom = "${b.pos_y}px";
      }
    }
  }

  /// Draws list of visible Blocks on screen
  void updateGame(Model model) {

    this.drawBlocks(model);

    this.player.style.bottom = "${model.player.pos_y}px";

    this.score.text = "Score: ${model.score}";

  }

  /// Updates visual quality
  void updateQuality(Quality quality) {
    switch (quality) {
      case Quality.HIGH:
        this.player.className = "Player block";
        this.qualityClass["Bullet"] = "Bullet block";
        this.qualityClass["Cobble"] = "Cobble block";
        this.qualityClass["Coin"] = "Coin block";
        this.qualityClass["Finish"] = "Finish block";
        this.qualityClass["Ground"] = "Ground block";
        this.qualityClass["Message"] = "Message block";
        this.qualityClass["SpikesBottom"] = "SpikesBottom block";
        this.qualityClass["SpikesTop"] = "SpikesTop block";
        this.qualityClass["Teleport"] = "Teleport block";
        this.qualityClass["Trigger"] = "Trigger block-low";
        this.qualityClass["Wall"] = "Wall block";
        this.qualityClass["Water"] = "Water block";

        this.menuButtonQuality.text = "Quality: High";
        break;
      case Quality.MEDIUM:
        this.player.className = "Player-low block-med";
        this.qualityClass["Bullet"] = "Bullet-low block-med";
        this.qualityClass["Cobble"] = "Cobble-low block-med";
        this.qualityClass["Coin"] = "Coin-low block-med";
        this.qualityClass["Finish"] = "Finish-low block-med";
        this.qualityClass["Ground"] = "Ground-low block-med";
        this.qualityClass["Message"] = "Message block";
        this.qualityClass["SpeedBlock"] = "Trigger block-med";
        this.qualityClass["SpikesBottom"] = "SpikesBottom-low block-med";
        this.qualityClass["SpikesTop"] = "SpikesTop-low block-med";
        this.qualityClass["Teleport"] = "Teleport-low block-med";
        this.qualityClass["Trigger"] = "Trigger block-med";
        this.qualityClass["Wall"] = "Wall-low block-med";
        this.qualityClass["Water"] = "Water-low block-med";

        this.menuButtonQuality.text = "Quality: Medium";
        break;
      case Quality.LOW:
        this.player.className = "Player-low block-low";
        this.qualityClass["Bullet"] = "Bullet-low block-low";
        this.qualityClass["Cobble"] = "Cobble-low block-low";
        this.qualityClass["Coin"] = "Coin-low block-low";
        this.qualityClass["Finish"] = "Finish-low block-low";
        this.qualityClass["Ground"] = "Ground-low block-low";
        this.qualityClass["Message"] = "Message block";
        this.qualityClass["SpikesBottom"] = "SpikesBottom-low block-low";
        this.qualityClass["SpikesTop"] = "SpikesTop-low block-low";
        this.qualityClass["Teleport"] = "Teleport-low block-low";
        this.qualityClass["Trigger"] = "Trigger block-low";
        this.qualityClass["Wall"] = "Wall-low block-low";
        this.qualityClass["Water"] = "Water-low block-low";

        this.menuButtonQuality.text = "Quality: Low";
        break;
    }
  }

  void updateLimiter(bool limited) {
    if (!limited) {
      this.menuButtonLimiter.text = "Framerate: 60fps";
    } else {
      this.menuButtonLimiter.text = "Framerate: 30fps";
    }
  }

  /// Hides menus to display game
  void onStart(Model m) {
    this.restartOverlay.style.display = "none";
    this.menuOverlay.style.display = "none";
    this.player.style.display = "block";
    this.score.style.display = "inline";

    this.player.style.height = "${m.player.size_y}px";
    this.player.style.width = "${m.player.size_x}px";
    this.player.style.left = "${Player.player_offset}px";

    this.showHighscoreSubmit();
  }

  /// Displays the main menu
  void showMenu(Model m) {
    this.menuOverlay.style.display = "inline";
    this.restartOverlay.style.display = "none";
    this.score.style.display = "none";

    this.menuLevelSelect.nodes.clear();
    m.levels.forEach((k, v) {
      OptionElement option = new Element.tag("option");
      option.text = k;
      option.value = v;
      this.menuLevelSelect.add(option,null);
    });

  }

  /// Displays login mask
  void showHighscoreLogin() {
    this.restartLogin.style.display = "inline";
  }

  /// Hides login mask
  void hideHighscoreLogin() {
    this.restartLogin.style.display = "none";
  }

  void hideHighscoreSubmit() {
    this.restartButtonSubmit.style.display = "none";
  }

  void showHighscoreSubmit() {
    this.restartButtonSubmit.style.display = "inline-block";
  }


  /// Updates the highscore table
  void showHighscore(Model m) {
    this.restartHighscoreList.children.clear();
    LIElement lientry;

    m.highscores.forEach((entry) {
        lientry = new LIElement();
        lientry.text = "${entry["score"]} ${entry["name"]}";
        this.restartHighscoreList.children.add(lientry);
    });
  }

  /// Displays the won/fail menu
  void onStop(Model m) {
    divs.forEach((div) {
      div.style.display = "none";
      div.dataset["id"] = "none";
    });

    this.player.style.display = "none";

    this.restartOverlay.style.display = "inline";

    this.score.text = "Score: ${m.score}";

    this.hideHighscoreLogin();

    if (m.state == State.WON) {
      this.restartMessage.text = "Well done";
    } else {
      this.restartMessage.text = "You fail";
    }

    this.showHighscore(m);

  }

}