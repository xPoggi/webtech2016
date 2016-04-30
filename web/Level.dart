import 'blocks/Block.dart';
import 'blocks/Ground.dart';
import 'dart:convert';

class Level {

  int speed;
  List<Block> blockList;

  Level(String jsonString) {
    this.blockList = new List<Block>();

    try {
      Map jsonData = JSON.decode(jsonString);
      var blocks = jsonData["blocks"];
      if (blocks != null) {
        for (Map m in jsonData["blocks"]) {
          switch (m["type"]) {
            case "Ground":
              print(blockList.length);
              var newGround = new Ground(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList.add(newGround);
              break;
          }
        }
      }
    } catch (e, ex) {
      print(e);
      print(ex);
    }

    print(this.blockList);

  }


  //note: onVisible or similar mechanics are a stupid solution, use a trigger
  void onUpdate() {

  }

}