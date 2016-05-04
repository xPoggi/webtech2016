part of runner;

class View {

  DivElement container;
  DivElement gameElement;

  DivElement restartOverlay;
  DivElement restart;
  DivElement restartMenu;

  DivElement menuOverlay;
  DivElement menu;
  SelectElement menuLevelSelect;

  DivElement score;
  DivElement message;
  DivElement statusMessage;

  int viewport_x;
  int viewport_y;

  List<DivElement> divs;
  DivElement player;
  Map<int, DivElement> usedDivs;



  View(int viewport_x, int viewport_y) {
    log("View!");
    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;

    this.divs = new List<DivElement>();

    // create 20 divs and store them for use, avoid expensive creation while running
    for (int i = 0; i < 20; i++) {
      divs.add(new DivElement());
    }

    usedDivs = new Map<int, DivElement>();

    this.container = querySelector('#container');

    this.gameElement = new DivElement();
    this.gameElement.id = "game";
    this.gameElement.style.width  = this.viewport_x.toString() + "px";
    this.gameElement.style.height = this.viewport_y.toString() + "px";
    this.container.children.add(this.gameElement);

    for (DivElement d in divs) {
      this.gameElement.children.add(d);
    }

    this.player = new DivElement();
    this.player.id = "Player";
    this.player.style.display = "block";
    this.gameElement.children.add(this.player);

    this.restartOverlay = new DivElement();
    this.restartOverlay.id = "restart-overlay";
    this.gameElement.children.add(this.restartOverlay);

    this.restart = new DivElement();
    this.restart.id = "restart";
    this.restart.text = "Touch or press Space to restart";
    this.restartOverlay.children.add(this.restart);

    this.restartMenu = new DivElement();
    this.restartMenu.id = "restartMenu";
    this.restartMenu.text = "Return to menu";
    this.restartOverlay.children.add(this.restartMenu);

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

    this.menu = new DivElement();
    this.menu.id = "menuStart";
    this.menu.text = "Start";
    this.menuOverlay.children.add(this.menu);

    this.menuLevelSelect = new SelectElement();
    this.menuLevelSelect.id = "menuLevelSelect";

    this.menuOverlay.children.add(this.menuLevelSelect);


  }

  DivElement getUnusedDivElement() {
    for (DivElement d in divs) {
      if ( !(usedDivs.containsValue(d)) ) {
        return d;
      }
    }
  }

  void setDiv(int id, String name) {

    DivElement d = getUnusedDivElement();
    d.className = name;
    usedDivs[id] = d;
    usedDivs[id].style.display = "block";

  }

  void setPlayerPos(int x, int y) {
    this.player.style.left = x.toString() + "px";
    this.player.style.bottom = y.toString() + "px";
  }

  void setDynamicWidthDiv(DivElement d, int pos_x, int size_x) {

    if (((pos_x + size_x) > viewport_x) && (pos_x < 0)) {
      d.style.width = (this.viewport_x).toString() + "px";
      d.style.left = "0px";
    } else if ((pos_x + size_x) > viewport_x) {
      d.style.width = (this.viewport_x - pos_x).toString() + "px";
      d.style.left = pos_x.toString() + "px";
    } else if (pos_x < 0) {
      d.style.width = (size_x + pos_x).toString() + "px";
      d.style.left = "0px";
    } else {
      d.style.width = size_x.toString() + "px";
      d.style.left = pos_x.toString() + "px";
    }
  }

  void setDynamicHeightDiv(DivElement d, int pos_y, int size_y) {
    if (((pos_y + size_y) > viewport_y) && (pos_y < 0)) {
      d.style.height = (this.viewport_y).toString() + "px";
      d.style.bottom = "0px";
    } else if ((pos_y + size_y) > viewport_y) {
      d.style.height = (this.viewport_y - pos_y).toString() + "px";
      d.style.bottom = pos_y.toString() + "px";
    } else if (pos_y < 0) {
      d.style.height = (size_y + pos_y).toString() + "px";
      d.style.bottom = "0px";
    } else {
      d.style.height = size_y.toString() + "px";
      d.style.bottom = pos_y.toString() + "px";
    }
  }

  void update(Model m) {
    if (m.running) {
      updateGame(m);
    } else if (m.inMenu) {
      showMenu(m);
    } else {
      onStop(m);
    }
  }

  //draws list of blocks on screen
  void updateGame(Model m) {
    for (Block b in m.visibleBlocks) {
      if ( !(usedDivs.containsKey(b.id)) ) {
        setDiv(b.id, b.name);
      }
//      usedDivs[b.id].style.bottom = (b.pos_y).toString() + "px";
//      usedDivs[b.id].style.height = (b.size_y).toString() + "px";
//      usedDivs[b.id].style.left = (b.pos_x - m.playerPosX).toString() + "px";
//      usedDivs[b.id].style.width = (b.size_x).toString() + "px";
      setDynamicHeightDiv(usedDivs[b.id], b.pos_y, b.size_y);
      setDynamicWidthDiv(usedDivs[b.id], b.pos_x - m.playerPosX, b.size_x);
    }

    var toRemove = new List<int>();
    usedDivs.forEach((i, div) {
      if ( m.visibleBlocks.where((b) => b.id == i).isEmpty ) {
        div.style.display = "none";
        toRemove.add(i);
      }
    });

    toRemove.forEach((i) {
      usedDivs.remove(i);
    });

//    this.setPlayerPos(m.p.pos_x, m.p.pos_y);
//    this.player.style.height = m.p.size_y.toString() + "px";
    setDynamicHeightDiv(this.player, m.p.pos_y,m.p.size_y);
    this.player.style.left = m.p.pos_x.toString() + "px";
    this.player.style.width = m.p.size_x.toString() + "px";

    this.score.text = "Score: " + m.score.toString();

  }

  void onStart() {
    this.restartOverlay.style.display = "none";
    this.menuOverlay.style.display = "none";
    this.player.style.display = "block";
    this.score.style.display = "inline";
  }

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

  void onStop(Model m) {

    usedDivs.forEach((i, div) {
      div.style.display = "none";
    });
    usedDivs.clear();

    this.player.style.display = "none";
//    this.score.style.display = "none";

    this.restartOverlay.style.display = "inline";

    if (m.won) {
      this.message.text = "Well done";
    } else {
      this.message.text = "You fail";
    }

  }

}