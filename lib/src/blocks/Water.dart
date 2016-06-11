part of runner;

class Water extends Block {

  Water(int id, int pos_x, int pos_y, int size_x, int size_y) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = true;
    this.isDeadly = true;
    this.name = "Water block-border";
    this.nameLow = "Water-low block-border-low";
  }
}