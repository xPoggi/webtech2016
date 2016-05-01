import 'blocks/Block.dart';
import 'blocks/Ground.dart';
import 'blocks/Finish.dart';
import 'blocks/Water.dart';
import 'dart:convert';
import 'blocks/Bullet.dart';
import 'blocks/Trigger.dart';

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
              var newGround = new Ground(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList.add(newGround);
              break;

            case "Finish":
              var newFinish = new Finish(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList.add(newFinish);
              break;

            case "Water":
              var newWater = new Water(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList.add(newWater);
              break;

            case "Trigger":
              var b = m["bullet"];

              var newBullet = new Bullet(
                  blockList.length, b["pos_x"], b["pos_y"], b["size_x"],
                  b["size_y"]);
              print(newBullet);
              blockList.add(newBullet);

              var newTrigger = new Trigger(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], newBullet);
              print(newTrigger);
              blockList.add(newTrigger);
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