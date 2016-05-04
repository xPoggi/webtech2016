part of runner;

class Player {

  //fall values
  static double gravity = 0.8;
  double maxVelocity = 8.0;
  static const int speed = 5;

  //pos size vel
  int pos_y;
  int pos_x;

  int size_x;
  int size_y;
  double velocity_y;

  //state
  bool jumping;
  bool doubleJump;
  bool grounded;

  Player() {
    this.pos_y = 50;
    this.pos_x = 50; // move slightly to the right

    this.size_x = 20;
    this.size_y = 50;

    this.velocity_y = -1.0;

    this.jumping = true;
    this.doubleJump = false;
    this.grounded = false;
  }

  void jump() {
    log("Player: Jump");
    if (this.jumping && !this.doubleJump) {
      log("Player: Double Jump");
      this.doubleJump = true;
      velocity_y = speed * 2.0;
    }
    if (!this.jumping && this.grounded) {
      log("Player: Jumping");
      jumping = true;
      grounded = false;
      velocity_y = speed * 2.0;
    }
  }

  void fall() {
    this.grounded = false;
  }

  void hitRoof() {
    this.jumping = true;
    this.doubleJump = true;
    this.velocity_y = -1.0;
  }

  void update() {
    if (!grounded) {
      this.pos_y = (this.pos_y + velocity_y).round();
      this.velocity_y -= gravity;
      if (this.velocity_y < -this.maxVelocity) { // don't accelerate to stupid falling speeds
        this.velocity_y = -this.maxVelocity;
      }
    }
//    print("Player: " + this.pos_x.toString() + " " + this.pos_y.toString());
  }

  int getPosY() {
    return this.pos_y;
  }

  double centerX() {
    return (this.pos_x + (this.size_x/2));
  }

  double centerY() {
    return (this.pos_y + (this.size_y/2));
  }

  void landed() {
    this.velocity_y = 0.0;
    this.grounded = true;
    this.jumping = false;
    this.doubleJump = false;
  }

  void reset() {
    this.pos_y = 50;
    this.pos_x = 50; // move slightly to the right
    this.landed();
  }

  void onCollision(String direction) {
    //TODO: see collision detection
  }

}