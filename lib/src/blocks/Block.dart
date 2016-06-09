part of runner;

class Block {

  //position and size
  int pos_x;
  int pos_y;
  int size_x;
  int size_y;
  int id;
  String name = "block-border";

  //if object is moving faster than game, set speed_x != 0
  int speed_x = 0;
  bool isDeadly;
  bool canCollide;
  bool isVisible = true;

  Block(int id, int pos_x, int pos_y, int size_x, int size_y) {
    this.id = id;
    this.pos_x = pos_x;
    this.pos_y = pos_y;
    this.size_x = size_x;
    this.size_y = size_y;
  }

  double centerX() {
    return (this.pos_x + (this.size_x/2));
  }

  double centerY() {
    return (this.pos_y + (this.size_y/2));
  }

  bool onCollision(Model m, Player p, Direction d) {
    if (isDeadly) {
      m.fail();
      log("${this.name} ${this.id} killed player, coming from ${d}");
      return false;
    } else {
      return true;
    }
  }

  void onUpdate() {
    if (speed_x != 0) {
      this.pos_x += speed_x;
    }
  }

  String toString() {
    var buffer = new StringBuffer();
    buffer.write(this.name);
    buffer.write(" ");
    buffer.write(this.id);
    buffer.write(" ");
    buffer.write(this.size_x);
    buffer.write(" ");
    buffer.write(this.size_y);
    buffer.write(" ");
    buffer.write(this.pos_x);
    buffer.write(" ");
    buffer.write(this.pos_y);
    buffer.write(" ");
    buffer.write(this.speed_x);
    return buffer.toString();
  }

}