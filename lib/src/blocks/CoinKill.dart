part of runner;

class CoinKill extends Coin {

  CoinKill(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y, 0) {
    this.canCollide = true;
    this.isDeadly = true;
    this.name = "Coin";
  }

  @override
  bool onCollision(Model m, Player p, Direction d) {
    log("CoinKill collision!");
    m.fail();
    return false;
  }

}