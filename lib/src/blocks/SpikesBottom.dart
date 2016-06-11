part of runner;

class SpikesBottom extends Block {

  SpikesBottom(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "SpikesBottom block";
    this.nameLow = "SpikesBottom-low block-border-low";
  }

  //kills from bottom, not from top
  @override
  bool onCollision(Model m, Player p, Direction d) {
    log("${this.name} ${this.id} collision with player, coming from ${d}");
    if (d == Direction.LEFT || d == Direction.RIGHT || d == Direction.TOP) {
      log("${this.name} ${this.id} killed player, coming from ${d}");
      m.fail();
      return false; //didn't land
    }
    else {
      return true;
    }
    return true; //landed
  }
}