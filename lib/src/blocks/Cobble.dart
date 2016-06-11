part of runner;

class Cobble extends Ground {

  Cobble(int id, int pos_x, int pos_y, int size_x, int size_y)
      : super(id, pos_x, pos_y, size_x, size_y) {
    this.name = "Cobble block";
    this.nameLow = "Cobble-low block-border-low";
  }
}