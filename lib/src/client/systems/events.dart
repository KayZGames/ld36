part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Orientation> om;
  Mapper<Position> pm;
  Mapper<Acceleration> am;
  Mapper<Brake> bm;
  Mapper<Controller> cm;

  WebSocket webSocket;

  InputHandlingSystem(this.webSocket)
      : super(Aspect.getAspectForAllOf(
            [Controller, Position, Orientation, Acceleration, Brake]));

  @override
  void processEntity(Entity entity) {
    var o = om[entity];
    var a = am[entity];
    var b = bm[entity];
    var c = cm[entity];
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
    if ((isPressed(KeyCode.X) || isPressed(KeyCode.J)) && c.arrowCooldown <= 0.0) {
      var p = pm[entity];
      print(c.arrowCooldown);
      c.arrowCooldown = c.maxArrowCooldown;
      world.createAndAddEntity([
        new Position(p.xyz.x, p.xyz.y),
        new Orientation(o.angle),
        new Velocity(250 * cos(o.angle), 250 * sin(o.angle)),
        new Arrow(),
        new SpriteName('arrow')
      ]);
    }
    c.arrowCooldown -= world.delta;
  }
}
