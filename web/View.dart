import 'dart:html';
import 'blocks/Block.dart';
import 'Player.dart';
import 'Model.dart';

class View {

  DivElement container;
  DivElement gameElement;

  DivElement restartOverlay;
  DivElement restart;

  int viewport_x;
  int viewport_y;

  List<DivElement> divs;
  DivElement player;
  Map<int, DivElement> usedDivs;



  View(int viewport_x, int viewport_y) {
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
    this.restart.text = "Touch or press Space to start";
    this.restartOverlay.children.add(this.restart);

  }

  DivElement getUnusedDivElement() {
    for (DivElement d in divs) {
      if ( !(usedDivs.containsValue(d)) ) {
        return d;
      }
    }
  }

  void setUnusedDivElements(int index) {
    try {
      for (int i in usedDivs.keys) {
        if (i < index) {
          usedDivs[i].style.display = "none";
          usedDivs.remove(i);
        }
      }
    } catch(e) {
      print(e);
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

    if ((pos_x + size_x) > viewport_x) {
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

  //draws list of blocks on screen
  void updateGame(Model m) {
    for (Block b in m.visibleBlocks) {
      if ( !(usedDivs.containsKey(b.id)) ) {
        setDiv(b.id, b.name);
      }
      usedDivs[b.id].style.bottom = (b.pos_y).toString() + "px";
      usedDivs[b.id].style.height = (b.size_y).toString() + "px";
//      usedDivs[b.id].style.left = (b.pos_x - m.playerPosX).toString() + "px";
//      usedDivs[b.id].style.width = (b.size_x).toString() + "px";
      setDynamicWidthDiv(usedDivs[b.id], b.pos_x - m.playerPosX, b.size_x);
    }

    this.setPlayerPos(m.p.pos_x, m.p.pos_y);

  }

  void onStart() {
    this.restartOverlay.style.display = "none";
    this.player.style.display = "block";
  }

  void onStop() {

    usedDivs.forEach((i, div) {
      div.style.display = "none";
    });
    usedDivs.clear();

    this.player.style.display = "none";

    this.restartOverlay.style.display = "inline";
  }

}