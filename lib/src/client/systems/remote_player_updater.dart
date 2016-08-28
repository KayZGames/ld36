part of client;

class RemotePlayerUpdater extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Orientation> om;
  Mapper<SpriteName> sm;
  TagManager tm;
  GroupManager gm;

  WebSocket webSocket;

  List<int> playersToRemove = new List<int>();
  Set<int> knownPlayers = new Set();

  RemotePlayerUpdater(this.webSocket)
      : super(Aspect
            .getAspectForAllOf([Position, Orientation, SpriteName]).exclude(
                [Remote, NoTransmission]));

  @override
  void initialize() {
    webSocket.onMessage.listen((event) {
      var data = JSON.decode(event.data);
      if (data['content'] != null) {
        var content = data['content'];
        var senderId = data['id'];
        if (content == 'removeClient') {
          knownPlayers.remove(senderId);
          playersToRemove.add(senderId);
        } else {
          try {
            handleJsonContent(content, senderId);
          } catch (_) {}
        }
      }
    });
  }

  void handleJsonContent(String json, int senderId) {
    var content = JSON.decode(json);
    if (content['type'] == 'chariot') {
      if (knownPlayers.contains(senderId)) {
        var entity = tm.getEntity('$playerTag$senderId');
        var p = pm[entity];
        var o = om[entity];
        p.xyz.x = content['x'];
        p.xyz.y = content['y'];
        o.angle = content['angle'];
      } else {
        if (!knownPlayers.contains(senderId)) {
          var entity = world.createAndAddEntity([
            new Position(content['x'], content['y']),
            new Orientation(content['angle']),
            new SpriteName('chariot'),
            new Remote(senderId),
          ]);
          knownPlayers.add(senderId);
          tm.register(entity, '$playerTag$senderId');
          gm.add(entity, remotePlayerGroup);
        }
      }
    } else if (content['type'] == 'arrow') {
      var angle = content['angle'];
      var entity = world.createAndAddEntity([
        new Position(content['x'], content['y']),
        new Orientation(angle),
        new Velocity(350 * cos(angle), 350 * sin(angle)),
        new Arrow(),
        new Remote(senderId),
        new SpriteName('arrow'),
        new Lifetime(2.5)
      ]);
      gm.add(entity, remoteArrowGroup);
    }
  }

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var o = om[entity];
    var s = sm[entity];

    webSocket.send(JSON.encode(
        {'type': s.name, 'x': p.xyz.x, 'y': p.xyz.y, 'angle': o.angle}));
  }

  @override
  void end() {
    playersToRemove
        .map((playerId) => tm.getEntity('$playerTag$playerId'))
        .where((entity) => entity != null)
        .forEach((entity) {
      entity.deleteFromWorld();
    });
    playersToRemove.clear();
  }
}

class SingleTransmissionSystem extends EntityProcessingSystem {
  SingleTransmissionSystem() : super(Aspect.getAspectForAllOf([Arrow]));

  @override
  void processEntity(Entity entity) {
    entity.addComponent(new NoTransmission());
    entity.changedInWorld();
  }
}
