part of runner;

class Level {

  int speed;
  List<Block> blockList;
  Spawn spawn;

  Level(String jsonString) {
    this.blockList = new List<Block>();

    try {
      Map jsonData = JSON.decode(jsonString);
      var lvlspwn = jsonData["spawn"];
      this.spawn = new Spawn(0, lvlspwn["pos_x"], lvlspwn["pos_y"], lvlspwn["size_x"], lvlspwn["size_y"]);

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

            case "Coin":
              var newCoin = new Coin(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], m["value"]);
              blockList.add(newCoin);
              break;

            case "Teleport":
              var b = m["target"];

              var newSpawn = new Spawn(
                  blockList.length, b["pos_x"], b["pos_y"], b["size_x"],
                  b["size_y"]);
              blockList.add(newSpawn);

              var newTeleport = new Teleport(blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], newSpawn);
              blockList.add(newTeleport);
              break;


            case "Trigger":
              var b = m["bullet"];

              var newBullet = new Bullet(
                  blockList.length, b["pos_x"], b["pos_y"], b["size_x"],
                  b["size_y"]);
              log(newBullet);
              blockList.add(newBullet);

              var newTrigger = new Trigger(
                  blockList.length, m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], newBullet);
              log(newTrigger);
              blockList.add(newTrigger);
              break;
          }
        }
      }
    } catch (e, ex) {
      print(e);
      print(ex);
    }

  }


  //note: onVisible or similar mechanics are a stupid solution, use a trigger
  void onUpdate() {

  }

}