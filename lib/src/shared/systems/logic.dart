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

class LocalArrowRemoteHitDetectionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  GroupManager gm;
  LocalArrowRemoteHitDetectionSystem()
      : super(Aspect.getAspectForAllOf([Position, Arrow]).exclude([Remote]));

  @override
  void processEntity(Entity entity) {
    var remotePlayers = gm.getEntities(remotePlayerGroup);
    for (var remotePlayer in remotePlayers) {
      var p = pm[remotePlayer];

      var ap = pm[entity];

      if ((ap.xyz - p.xyz).length < 25) {
        world.createAndAddEntity([
          new SpriteName('blood'),
          new Position(ap.xyz.x, ap.xyz.y),
          new Orientation(0.0),
          new Lifetime(30.0),
          new Background()
        ]);
        entity.deleteFromWorld();
        break;
      }
    }
  }
}

class RemoteArrowLocalHitDetectionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Health> hm;
  Mapper<Orientation> om;
  TagManager tm;
  GameStateManager gsm;
  RemoteArrowLocalHitDetectionSystem()
      : super(Aspect.getAspectForAllOf([Position, Arrow, Remote]));

  @override
  void processEntity(Entity entity) {
    var player = tm.getEntity(playerTag);
    var p = pm[player];

    var ap = pm[entity];

    if ((ap.xyz - p.xyz).length < 25) {
      world.createAndAddEntity([
        new SpriteName('blood'),
        new Position(ap.xyz.x, ap.xyz.y),
        new Orientation(0.0),
        new Lifetime(30.0),
        new Background()
      ]);
      entity.deleteFromWorld();
      var health = hm[player];
      health.value--;
      if (health.value <= 0) {
        gsm.gameOver(0);
        player.deleteFromWorld();
        world.createAndAddEntity([
          new SpriteName('corpse'),
          new Position(p.xyz.x, p.xyz.y),
          new Orientation(om[player].angle),
          new Lifetime(30.0),
          new Background(),
          new Corpse()
        ]);
      }
    }
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) != null;


}

class RemoteArrowRemoteHitDetectionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Remote> rm;

  GroupManager gm;
  RemoteArrowRemoteHitDetectionSystem()
      : super(Aspect.getAspectForAllOf([Position, Arrow, Remote]));

  @override
  void processEntity(Entity entity) {
    var remotePlayers = gm.getEntities(remotePlayerGroup);
    for (var remotePlayer in remotePlayers) {
      var r = rm[remotePlayer];
      var ra = rm[entity];
      if (r.id == ra.id) {
        continue;
      }
      var p = pm[remotePlayer];

      var ap = pm[entity];

      if ((ap.xyz - p.xyz).length < 25) {
        world.createAndAddEntity([
          new SpriteName('blood'),
          new Position(ap.xyz.x, ap.xyz.y),
          new Orientation(0.0),
          new Lifetime(30.0),
          new Background()
        ]);
        entity.deleteFromWorld();
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

class ArenaSizeCalculatingSystem extends EntitySystem {
  GameStateManager gsm;

  ArenaSizeCalculatingSystem() : super(Aspect.getAspectForAllOf([Player]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var targetRadius = sqrt(entities.length) * 500.0;
    gsm.playerCount = entities.length;

    gsm.arenaRadius =
        (1.0 - world.delta) * gsm.arenaRadius + world.delta * targetRadius;
  }

  @override
  bool checkProcessing() => true;
}

class InBorderKeepingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  GameStateManager gsm;
  InBorderKeepingSystem() : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];

    if (gsm.arenaRadius < p.xyz.length) {
      p.xyz = p.xyz.normalized() * gsm.arenaRadius;
    }
  }
}
