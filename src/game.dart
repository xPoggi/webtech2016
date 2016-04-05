// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';

DivElement player;
const int speed = 5;
const int tickRate = 16;
bool moveLeft = false;
bool moveTop = false;



void main() {
  player = querySelector('#player');
  player.style.backgroundColor= "yellow";
  new Timer.periodic(const Duration(milliseconds:tickRate), tick);

}

void tick(Timer t) {
  try {
    var posHorizontal = getLeft(player);
    var posVertical   = getTop(player);
    if ((posHorizontal < 290) && !moveLeft) {
      player.style.left = (posHorizontal + speed).toString() + "px";
    } else if (((posHorizontal >= 290) && !moveLeft)) {
      moveLeft = true;
    } else if (((posHorizontal > 0) && moveLeft)) {
      player.style.left = (posHorizontal - speed).toString() + "px";
    } else if (((posHorizontal >= 0) && moveLeft)) {
      moveLeft = false;
    }
    if ((posVertical < 490) && !moveTop) {
      player.style.top = (posVertical + speed).toString() + "px";
    } else if (((posVertical >= 490) && !moveTop)) {
      moveTop = true;
    } else if (((posVertical > 0) && moveTop)) {
      player.style.top = (posVertical - speed).toString() + "px";
    } else if (((posVertical >= 0) && moveTop)) {
      moveTop = false;
    }
  } catch(exception, stackTrace) {
    print(exception);
    print(stackTrace);
  }
}

int getLeft(Element element) {
  print("Top: " + element.style.left);
  return int.parse(element.style.left.replaceAll('px', ''));
}

int getTop(Element element) {
  print("Top: " + element.style.top);
  return int.parse(element.style.top.replaceAll('px', ''));
}
