part of runner;

class Bullet extends Block {

  Bullet(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = true;
    this.name = "Bullet";
  }

  void start() {
    this.speed_x = -2;
  }

}