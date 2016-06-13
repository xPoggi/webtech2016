part of runner;

class TeleportSpeed extends Teleport {

  Spawn spawn;
  int speedIncrease;

  TeleportSpeed(int id, int pos_x, int pos_y, int size_x, int size_y, Spawn s, int speedIncrease) : super(id, pos_x, pos_y, size_x, size_y, s) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Teleport";
    this.spawn = s;
    this.speedIncrease = speedIncrease;
  }

  //returns true if landed, false if not
  @override
  bool onCollision(Model m, Player p, Direction d) {
    m.speed += this.speedIncrease;
    p.reset();
    m.resetVisibleIndex();
    m.player.pos_x = this.spawn.pos_x + m.player.pos_x;
    p.pos_y = this.spawn.pos_y;
    return false;
  }
}