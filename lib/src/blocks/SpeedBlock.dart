part of runner;

class SpeedBlock extends Block {

  int speedIncrease;
  bool collected;

  SpeedBlock(int id, int pos_x, int pos_y, int size_x, int size_y, int speed) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "SpeedBlock";
    this.speedIncrease = speed;
    this.isVisible = true;
  }

  //returns true if landed, false if not
  @override
  bool onCollision(Model m, Player p, Direction d) {
    if (!this.collected) {
      this.collected = true;
      m.speed += this.speedIncrease;
    }
    return false;
  }
}