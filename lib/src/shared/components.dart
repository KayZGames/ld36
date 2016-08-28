part of shared;

class Position extends Component {
  Vector3 xyz;
  Position(double x, double y) : xyz = new Vector3(x, y, 0.0);
}

class Controller extends Component {
  double arrowCooldown = 0.0;
  double maxArrowCooldown = 1.0;
}

class Orientation extends Component {
  double angle;
  double turnRate = PI / 72;
  Orientation(this.angle);
}

class Acceleration extends Component {
  double value;
  double maxAcceleration = 400.0;
  Acceleration() : this.value = 0.0;
}

class Brake extends Component {
  double value;
  double brakeForce = 10.0;
  Brake() : this.value = 0.0;
}

class Velocity extends Component {
  Vector3 xyz;
  Velocity(double x, double y) : xyz = new Vector3(x, y, 0.0);
}

class Arrow extends Component {}

class Remote extends Component {
  int id;
  Remote(this.id);
}

class NoTransmission extends Component {}

class SpriteName extends Component {
  String name;
  SpriteName(this.name);
}

class Lifetime extends Component {
  double value;
  Lifetime(this.value);
}

class Player extends Component {}

class Background extends Component {}