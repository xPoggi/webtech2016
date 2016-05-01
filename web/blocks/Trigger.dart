import 'Block.dart';
import '../Model.dart' show Direction, Model;
import '../Player.dart';
import 'Bullet.dart';

class Trigger extends Block {

  Bullet bullet;

  Trigger(int id, int pos_x, int pos_y, int size_x, int size_y, Bullet b) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Trigger";
    this.bullet = b;
  }

  //returns true if landed, false if not
  @override
  bool onCollision(Model m, Player p, Direction d) {
    this.bullet.start();
  }
}