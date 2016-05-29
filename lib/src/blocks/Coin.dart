part of runner;

class Coin extends Block {

  int value;
  bool collected;

  Coin(int id, int pos_x, int pos_y, int size_x, int size_y, int value) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Coin";
    this.value = value;
    this.collected = false;
  }

  @override
  bool onCollision(Model m, Player p, Direction d) {
    log("Coin collision!");
    if (!this.collected) {

      this.collected = true;
      this.isVisible = false;
      m.points += this.value;

    }
    return false;
  }

}