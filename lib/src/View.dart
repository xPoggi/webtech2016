part of runner;

class View {


  // game containers
  DivElement container;
  DivElement gameElement;

  /// Restart overlay container
  DivElement restartOverlay;

  /// Restart clickables container
  DivElement restartButtons;
  DivElement restart;
  DivElement restartMenu;
  DivElement restartSubmitHighscore;

  /// Restart highscore list container
  DivElement restartHighscores;
  UListElement restartHighscoreList;

  /// Restart login container
  DivElement restartLogin;
  InputElement restartLoginUser;
  InputElement restartLoginPassword;
  DivElement restartLoginSubmit;


  /// Main menu overlay container
  DivElement menuOverlay;
  DivElement title;
  DivElement menuButtons;
  DivElement menu;
  SelectElement menuLevelSelect;
  DivElement menuLimiter;

  /// Score Element
  DivElement score;
  DivElement message;
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

    this.container = querySelector('#container');

    this.gameElement = new DivElement();
    this.gameElement.id = "game";
    this.gameElement.style.width  = "${this.viewport_x}px";
    this.gameElement.style.height = "${this.viewport_y}px";
    this.container.children.add(this.gameElement);

    for (DivElement d in divs) {
      this.gameElement.children.add(d);
      d.style.display = "none";
      d.dataset["id"] = "none";
    }

    this.player = new DivElement();
    this.player.id = "Player";
    this.player.style.display = "block";
    this.gameElement.children.add(this.player);

    this.restartOverlay = new DivElement();
    this.restartOverlay.id = "restart-overlay";
    this.gameElement.children.add(this.restartOverlay);

    this.restartButtons = new DivElement();
    this.restartButtons.id = "restartButtons";
    this.restartOverlay.children.add(this.restartButtons);

    this.restartHighscores = new DivElement();
    this.restartHighscores.id = "restartHighscores";
    this.restartOverlay.children.add(this.restartHighscores);

    this.restartHighscoreList = new UListElement();
    this.restartHighscoreList.id = "restartHighscoreList";
    this.restartHighscores.children.add(this.restartHighscoreList);

    this.restartLogin = new DivElement();
    this.restartLogin.id = "restartLogin";
    this.restartOverlay.children.add(this.restartLogin);

    this.restartLoginUser = new InputElement();
    this.restartLoginUser.id = "restartLoginUser";
    this.restartLoginUser.placeholder = "Username";
    this.restartLogin.children.add(this.restartLoginUser);

    this.restartLoginPassword = new InputElement();
    this.restartLoginPassword.id = "restartLoginPassword";
    this.restartLoginPassword.type = "password";
    this.restartLoginPassword.placeholder = "Password";
    this.restartLogin.children.add(this.restartLoginPassword);

    this.restartLoginSubmit = new DivElement();
    this.restartLoginSubmit.id = "restartLoginSubmit";
    this.restartLoginSubmit.text = "Submit";
    this.restartLogin.children.add(this.restartLoginSubmit);

    this.restart = new DivElement();
    this.restart.id = "restart";
    this.restart.text = "Restart Level";
    this.restartButtons.children.add(this.restart);

    this.restartSubmitHighscore = new DivElement();
    this.restartSubmitHighscore.id = "restartHighscore";
    this.restartSubmitHighscore.text = "Submit Highscore";
    this.restartButtons.children.add(this.restartSubmitHighscore);

    this.restartMenu = new DivElement();
    this.restartMenu.id = "restartMenu";
    this.restartMenu.text = "Return to menu";
    this.restartButtons.children.add(this.restartMenu);

    this.message = new DivElement();
    this.message.id = "message";
    this.message.text = "";
    this.restartOverlay.children.add(this.message);

    this.score = new DivElement();
    this.score.id = "score";
    this.score.text = "Score: 0";
    this.gameElement.children.add(this.score);

    this.statusMessage = new DivElement();
    this.statusMessage.id = "statusMessage";
    this.statusMessage.text = "";
    this.gameElement.children.add(this.statusMessage);

    this.menuOverlay = new DivElement();
    this.menuOverlay.id = "menu-overlay";
    this.gameElement.children.add(this.menuOverlay);

    this.title = new DivElement();
    this.title.id = "title";
    this.title.text = "'Til Death";
    this.menuOverlay.children.add(this.title);

    this.menuButtons = new DivElement();
    this.menuButtons.id = "restartButtons";
    this.menuOverlay.children.add(this.menuButtons);

    this.menu = new DivElement();
    this.menu.id = "menuStart";
    this.menu.text = "Start";
    this.menuButtons.children.add(this.menu);

    this.menuLevelSelect = new SelectElement();
    this.menuLevelSelect.id = "menuLevelSelect";
    this.menuButtons.children.add(this.menuLevelSelect);

    this.menuLimiter = new DivElement();
    this.menuLimiter.id = "menuLimiter";
    this.menuLimiter.text = "30fps - ✕";
    this.menuButtons.children.add(this.menuLimiter);

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

  void drawBlocks(Model m) {
    for (int i = 0; i < m.visibleBlocks.length; i++) {
      Block b = m.visibleBlocks[i];
      DivElement d = this.divs[i];
      if (b == null && d.style.display != "none") {
        d.style.display = "none";
        d.dataset["id"] = "none";
      } else if (b != null && ( (d.style.display == "none") || (d.dataset["id"] != b.id.toString()) )) {
        d.style.display = "block";
        d.className = b.name;
        d.dataset["id"] = b.id.toString();

        d.style.width = "${b.size_x}px";
        d.style.height = "${b.size_y}px";

        d.style.left = "${b.pos_x  - m.player.pos_x + Player.player_offset}px";
        d.style.bottom = "${b.pos_y}px";
      } else if (b != null) {
        d.style.left = "${b.pos_x  - m.player.pos_x + Player.player_offset}px";
        d.style.bottom = "${b.pos_y}px";
      }
    }
  }

  /// Draws list of visible Blocks on screen
  void updateGame(Model m) {

    this.drawBlocks(m);

    this.player.style.bottom = "${m.player.pos_y}px";

    this.score.text = "Score: ${m.score}";

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
    this.restartSubmitHighscore.style.display = "none";
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

    hideHighscoreLogin();

    if (m.state == State.WON) {
      this.message.text = "Well done";
    } else {
      this.message.text = "You fail";
    }

    this.showHighscore(m);

  }

}