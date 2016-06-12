part of runner;

class Trigger extends Block {

  List<Bullet> bullet;

  Trigger(int id, int pos_x, int pos_y, int size_x, int size_y, List<Bullet> b) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Trigger";
    this.bullet = b;
  }

  //returns true if landed, false if not
  @override
  bool onCollision(Model m, Player p, Direction d) {
    this.bullet.forEach((b) => b.start());
    return false;
  }
}