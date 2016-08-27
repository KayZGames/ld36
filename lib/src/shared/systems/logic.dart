part of shared;


class AccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Orientation> om;

  AccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity, Orientation]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var v = vm[entity];
    var o = om[entity];

    v.xyz.x += cos(o.angle) * a.value * world.delta;
    v.xyz.y += sin(o.angle) * a.value * world.delta;
  }
}

class BrakeSystem extends EntityProcessingSystem {
  Mapper<Brake> bm;
  Mapper<Velocity> vm;

  BrakeSystem() : super(Aspect.getAspectForAllOf([Brake, Velocity]));

  @override
  void processEntity(Entity entity) {
    var b = bm[entity];
    var v = vm[entity];

    v.xyz -= v.xyz * (b.value + 0.25) * world.delta;
  }
}

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    p.xyz += v.xyz * world.delta;
  }
}