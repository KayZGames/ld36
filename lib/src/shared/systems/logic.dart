part of shared;

class AccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Orientation> om;

  AccelerationSystem()
      : super(Aspect.getAspectForAllOf([Acceleration, Velocity, Orientation]));

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

    v.xyz -= v.xyz * (b.value + 0.5) * world.delta;
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

class ArrowHitDetectionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Orientation> om;

  GroupManager gm;
  ArrowHitDetectionSystem()
      : super(Aspect.getAspectForAllOf([Position, Orientation, Arrow]).exclude(
            [Remote]));

  @override
  void processEntity(Entity entity) {
    var remotePlayers = gm.getEntities(remotePlayerGroup);
    for (var remotePlayer in remotePlayers) {
      var p = pm[remotePlayer];
      var o = om[remotePlayer];

      var ap = pm[entity];

      if ((ap.xyz - p.xyz).length < 20) {
        world.createAndAddEntity([
          new SpriteName('blood'),
          new Position(ap.xyz.x, ap.xyz.y),
          new Orientation(0.0),
          new Lifetime(30.0)
        ]);
        entity.deleteFromWorld();
        break;
      }
    }
  }
}

class LifetimeExpirationSystem extends EntityProcessingSystem {
  Mapper<Lifetime> lm;
  LifetimeExpirationSystem() : super(Aspect.getAspectForAllOf([Lifetime]));

  @override
  void processEntity(Entity entity) {
    var l = lm[entity];
    l.value -= world.delta;

    if (l.value < 0.0) {
      entity.deleteFromWorld();
    }
  }
}
