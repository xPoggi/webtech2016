// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async' show Timer;
import 'dart:math' show Random;

const int speed = 5;
const int tickRate = 16;
const int gameHeight = 500;
const int gameWidth = 300;

log(String msg) {
  if (const String.fromEnvironment('DEBUG') != null) {
    print('debug: $msg');
  }
}

class Blob {

  static List<Blob> myBlobList = new List();

  DivElement myBlob;
  int speed = 5;
  bool moveLeft = false;
  bool moveTop = false;
  int blobSize = 10;

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
    myBlobList.add(this);
    print(myBlobList.length);
  }

  void tick(Timer t) {
    try {
      var posHorizontal = getLeft(this.myBlob);
      var posVertical   = getTop(this.myBlob);
      if ((posHorizontal < (gameWidth - blobSize)) && !moveLeft) {
        this.myBlob.style.left = (posHorizontal + this.speed).toString() + "px";
      } else if (((posHorizontal >= gameWidth - blobSize) && !moveLeft)) {
        this.moveLeft = true;
      } else if (((posHorizontal > 0) && moveLeft)) {
        myBlob.style.left = (posHorizontal - this.speed).toString() + "px";
      } else if (((posHorizontal <= 0) && moveLeft)) {
        this.moveLeft = false;
      }
      if ((posVertical < (gameHeight - blobSize)) && !moveTop) {
        this.myBlob.style.top = (posVertical + this.speed).toString() + "px";
      } else if (((posVertical >= (gameHeight - blobSize)) && !moveTop)) {
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
  int playerLeft = getLeft(element);
  if (playerLeft < (gameWidth - 15)) {
    element.style.left = (playerLeft + speed).toString() + "px";
  }
  element.children[0].style.display = "inline";
  element.children[1].style.display = "none";
}

void moveLeft(Element element) {
  int playerLeft = getLeft(element);
  if (playerLeft > 0) {
   element.style.left = (getLeft(element) - speed).toString() + "px";
  }
  element.children[0].style.display = "none";
  element.children[1].style.display = "inline";
}

void moveUp(Element element) {
  int playerTop = getTop(element);
  if (playerTop > 0) {
    element.style.top = (getTop(element) - speed).toString() + "px";
  }
}

void moveDown(Element element) {
  int playerTop = getTop(element);
  if (playerTop < (gameHeight - 15)) {
    element.style.top = (getTop(element) + speed).toString() + "px";
  }
}

int getLeft(Element element) {
  log("Left: " + element.style.left);
  return int.parse(element.style.left.replaceAll('px', ''));
}

int getTop(Element element) {
  log("Top: " + element.style.top);
  return int.parse(element.style.top.replaceAll('px', ''));
}