part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Orientation> om;
  Mapper<Acceleration> am;
  Mapper<Brake> bm;

  WebSocket webSocket;

  InputHandlingSystem(this.webSocket)
      : super(Aspect.getAspectForAllOf(
      [Controller, Position, Orientation, Acceleration, Brake]));

  @override
  void processEntity(Entity entity) {
    var o = om[entity];
    var a = am[entity];
    var b = bm[entity];
    if (up) {
      a.value = a.maxAcceleration;
      b.value = 1.0;
    } else if (down) {
      b.value = b.brakeForce;
      a.value = 0.0;
    } else {
      b.value = 1.0;
      a.value = 0.0;
    }
    if (left) {
      o.angle -= o.turnRate;
      a.value = a.maxAcceleration;
    } else if (right) {
      o.angle += o.turnRate;
      a.value = a.maxAcceleration;
    }
  }
}
