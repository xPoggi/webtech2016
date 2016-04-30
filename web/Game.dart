import 'dart:html';
import 'Model.dart';
import 'View.dart';
import 'dart:async';


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

    window.onKeyDown.listen((KeyboardEvent ev) {
      switch (ev.keyCode) {
        case KeyCode.UP:    this.jump(); break;
        case KeyCode.SPACE: this.jump(); break;
      }
    });

    window.onTouchStart.listen((TouchEvent ev) {
      this.jump();
    });

    view.restart.onClick.listen(
        (event) => this.startGame());

  }

  jump() async {
    if (!this.model.running) {
      this.startGame();
    } else {
      this.model.jump();
    }
  }

  void update(Timer t) {
    if (this.model.running) {
      this.model.update(t);
      this.view.updateGame(this.model);
    } else {
      this.timer.cancel();
      this.view.onStop();
    }
  }

  startGame() async {

    var currentLocation = window.location;
    var level1 = currentLocation.toString().replaceAll("index.html", "") + "levels/level1.json";

    var request = await HttpRequest.getString(level1).asStream().join();

    this.model.setLevel(request);

    this.timer = new Timer.periodic(const Duration(milliseconds: tickrate), this.update);
    this.view.onStart();
    this.model.start();

  }
}

void main() {

  Game g = new Game();

//  g.startGame();

}