import '../Model.dart' show Direction;

class Block {

  //position and size
  int pos_x;
  int pos_y;
  int size_x;
  int size_y;
  int id;
  String name = "Block";

  //if object is moving faster than game, set speed_x != 0
  int speed_x = 0;
  bool isDeadly;
  bool canCollide;

  Block(int id, int pos_x, int pos_y, int size_x, int size_y) {
    this.id = id;
    this.pos_x = pos_x;
    this.pos_y = pos_y;
    this.size_x = size_x;
    this.size_y = size_y;
  }

  bool onCollision(Direction d) {
    //TODO
    if (isDeadly) {
      return true;
    } else {
      return false;
    }
  }

  void onUpdate() {
    //TODO
  }

  String toString() {
    var buffer = new StringBuffer();
    buffer.write("Block ");
    buffer.write(this.id);
    buffer.write(" ");
    buffer.write(this.size_x);
    buffer.write(" ");
    buffer.write(this.size_y);
    buffer.write(" ");
    buffer.write(this.pos_x);
    buffer.write(" ");
    buffer.write(this.pos_y);
    return buffer.toString();
  }

}