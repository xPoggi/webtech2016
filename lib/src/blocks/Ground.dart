import 'Block.dart';
import '../Model.dart' show Direction, Model;
import '../Player.dart';

class Ground extends Block {

  Ground(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Ground";
  }

  //returns true if landed, false if not
  @override
  bool onCollision(Model m, Player p, Direction d) {
    if (d == Direction.LEFT) {
      m.fail();
      return false; //didn't land
    }
    if (d == Direction.TOP) {
      return true;
    }
    if (d == Direction.BOTTOM) {
      p.hitRoof();
      p.pos_y = this.pos_y - p.size_y;
      return false;
    }
    if (d == Direction.RIGHT) {
      return false; //didn't land
    }
    return true; //landed
  }
}