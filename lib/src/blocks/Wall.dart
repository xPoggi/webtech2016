part of runner;

class Wall extends Ground {

  Wall(int id, int pos_x, int pos_y, int size_x, int size_y)
      : super(id, pos_x, pos_y, size_x, size_y) {
    this.name = "Wall block";
  }
}