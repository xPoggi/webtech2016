// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async' show Timer;
import 'dart:math' show Random;

DivElement player;
int speed = 5;
const int tickRate = 16;

log(String msg) {
  if (const String.fromEnvironment('DEBUG') != null) {
    print('debug: $msg');
  }
}

class Blob {

  DivElement myBlob;
  int speed = 5;
  bool moveLeft = false;
  bool moveTop = false;

  Blob(DivElement parent, int height, int width) {
    myBlob = new DivElement();
    myBlob.className = "blob";
    Random rnd = new Random();
    myBlob.style.top = (rnd.nextInt(height)).toString() + "px";
    myBlob.style.left = (rnd.nextInt(width)).toString() + "px";
    this.moveLeft = rnd.nextBool();
    this.moveTop = rnd.nextBool();
    this.speed = 1 + rnd.nextInt(4);
    parent.children.add(myBlob);
  }

  void tick(Timer t) {
    try {
      var posHorizontal = getLeft(this.myBlob);
      var posVertical   = getTop(this.myBlob);
      if ((posHorizontal < 290) && !moveLeft) {
        this.myBlob.style.left = (posHorizontal + this.speed).toString() + "px";
      } else if (((posHorizontal >= 290) && !moveLeft)) {
        this.moveLeft = true;
      } else if (((posHorizontal > 0) && moveLeft)) {
        myBlob.style.left = (posHorizontal - this.speed).toString() + "px";
      } else if (((posHorizontal <= 0) && moveLeft)) {
        this.moveLeft = false;
      }
      if ((posVertical < 490) && !moveTop) {
        this.myBlob.style.top = (posVertical + this.speed).toString() + "px";
      } else if (((posVertical >= 490) && !moveTop)) {
        this.moveTop = true;
      } else if (((posVertical > 0) && moveTop)) {
        this.myBlob.style.top = (posVertical - this.speed).toString() + "px";
      } else if (((posVertical <= 0) && moveTop)) {
        this.moveTop = false;
      }
    } catch(exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
  }

}

void main() {
  DivElement base = querySelector('#game');

  for (var i = 0; i < 50; i++) {
    Blob a = new Blob(base, 500, 300);
    new Timer.periodic(const Duration(milliseconds: tickRate), a.tick);
  }

  DivElement player = querySelector('#player');

  window.onKeyDown.listen((KeyboardEvent ev) {
    switch (ev.keyCode) {
      case KeyCode.LEFT:  moveLeft(player); break;
      case KeyCode.RIGHT: moveRight(player); break;
      case KeyCode.UP:    moveUp(player); break;
      case KeyCode.DOWN:  moveDown(player); break;
    }
  });

}

void moveRight(Element element) {
  element.style.left = (getLeft(element) + speed).toString() + "px";
}

void moveLeft(Element element) {
  element.style.left = (getLeft(element) - speed).toString() + "px";
}

void moveUp(Element element) {
  element.style.top = (getTop(element) - speed).toString() + "px";
}

void moveDown(Element element) {
  element.style.top = (getTop(element) + speed).toString() + "px";
}

int getLeft(Element element) {
  log("Left: " + element.style.left);
  return int.parse(element.style.left.replaceAll('px', ''));
}

int getTop(Element element) {
  log("Top: " + element.style.top);
  return int.parse(element.style.top.replaceAll('px', ''));
}
