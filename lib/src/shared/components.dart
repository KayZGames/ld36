part of shared;


class Position extends Component {
  Vector3 xyz;
  Position(double x, double y) : xyz = new Vector3(x, y, 0.0);
}

class Controller extends Component {}

class Orientation extends Component {
  double angle;
  double turnRate = PI / 36;
  Orientation(this.angle);
}

class Acceleration extends Component {
  double value;
  double maxAcceleration = 200.0;
  Acceleration() : this.value = 0.0;
}

class Brake extends Component {
  double value;
  double brakeForce = 10.0;
  Brake() : this.value = 0.0;
}

class Velocity extends Component {
  Vector3 xyz;
  Velocity() : xyz = new Vector3.zero();
}