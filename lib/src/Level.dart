part of runner;

class Level {

  int speed;
  List<Block> blockList_static;
  List<Block> blockList_dynamic;
  Spawn spawn;

  Level(String jsonString) {
    List<Block> blockList_static = new List<Block>();
    List<Block> blockList_dynamic = new List<Block>();

    try {
      Map jsonData = JSON.decode(jsonString);
      this.speed = jsonData["speed"] ?? 5;
      var levelSpawn = jsonData["spawn"];
      this.spawn = new Spawn(0, levelSpawn["pos_x"], levelSpawn["pos_y"], levelSpawn["size_x"], levelSpawn["size_y"]);

      var blocks = jsonData["blocks"];
      if (blocks != null) {
        for (Map m in jsonData["blocks"]) {
          switch (m["type"]) {
            case "Ground":
              var newGround = new Ground(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newGround);
              break;

            case "Wall":
              var newWall = new Wall(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newWall);
              break;

            case "Cobble":
              var newCobble = new Cobble(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newCobble);
              break;

            case "Finish":
              var newFinish = new Finish(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newFinish);
              break;

            case "Water":
              var newWater = new Water(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newWater);
              break;

            case "SpikesTop":
              var newSpikes = new SpikesTop(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newSpikes);
              break;

            case "SpikesBottom":
              var newSpikes = new SpikesBottom(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              blockList_static.add(newSpikes);
              break;

            case "Coin":
              var newCoin = new Coin(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], m["value"] ?? 0);
              blockList_dynamic.add(newCoin);
              break;

            case "Teleport":
              var b = m["target"];

              var newSpawn = new Spawn(
                  blockList_static.length + (blockList_dynamic.length ?? 0), b["pos_x"], b["pos_y"], b["size_x"],
                  b["size_y"]);
              blockList_static.add(newSpawn);

              var newTeleport = new Teleport(blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], newSpawn);
              blockList_static.add(newTeleport);
              break;

            case "TeleportSpeed":
              var b = m["target"];

              var newSpawn = new Spawn(
                  blockList_static.length + (blockList_dynamic.length ?? 0), b["pos_x"], b["pos_y"], b["size_x"],
                  b["size_y"]);
              blockList_static.add(newSpawn);

              var newTeleportSpeed = new TeleportSpeed(blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], newSpawn, m["speedIncrease"]);
              blockList_static.add(newTeleportSpeed);
              break;

            case "Trigger":
              var bullets = m["bullets"];

              List<Bullet> bulletList = new List<Block>();

              for (Map b in bullets) {
                var newBullet = new Bullet(
                    blockList_static.length + (blockList_dynamic.length ?? 0), b["pos_x"], b["pos_y"], b["size_x"],
                    b["size_y"]);
                log(newBullet.toString());
                bulletList.add(newBullet);
                blockList_dynamic.add(newBullet);
              }


              var newTrigger = new Trigger(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], bulletList);
              log(newTrigger.toString());
              blockList_static.add(newTrigger);
              break;

            case "SpeedBlock":
              var newSpeedBlock = new SpeedBlock(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], m["speedIncrease"]);
              log(newSpeedBlock.toString());
              blockList_static.add(newSpeedBlock);
              break;

            case "CoinKill":
              var newCoinKill = new CoinKill(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"]);
              log(newCoinKill.toString());
              blockList_static.add(newCoinKill);
              break;

            case "Message":
              var newMessage = new Message(
                  blockList_static.length + (blockList_dynamic.length ?? 0), m["pos_x"], m["pos_y"], m["size_x"],
                  m["size_y"], m["message"]);
              log(newMessage.toString());
              blockList_static.add(newMessage);
              break;
          }
        }
      }

      // sort this to "accept" bad ordering in levels
      blockList_static.sort((a, b) => a.pos_x.compareTo(b.pos_x));
      blockList_dynamic.sort((a, b) => a.pos_x.compareTo(b.pos_x));
      this.blockList_static = new List<Block>.from(blockList_static, growable: false);
      this.blockList_dynamic = new List<Block>.from(blockList_dynamic, growable: false);
      blockList_dynamic = null;
      blockList_static = null;
    } catch (e, ex) {
      print(e);
      print(ex);
    }

  }

}