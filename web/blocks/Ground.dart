import 'Block.dart';
import '../Model.dart' show Direction;

class Ground extends Block {

  Ground(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y) {
    print(id);
    this.canCollide = true;
    this.isDeadly = false;
    this.name = "Ground";
  }

  @override
  bool onCollide(Direction d) {
    //get collision direction and kill player if deadly
    if (d != Direction.TOP) {
      return false;
    }
    return true;
  }
}