part of runner;

class Message extends Block {

  String message;

  Message(int id, int pos_x, int pos_y, int size_x, int size_y, String message) : super(id, pos_x, pos_y, size_x, size_y) {
    this.canCollide = false;
    this.isDeadly = false;
    this.name = "Message";
    this.message = message;
  }

}