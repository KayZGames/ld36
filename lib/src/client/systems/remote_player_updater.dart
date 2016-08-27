part of client;

class RemotePlayerUpdater extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Orientation> om;
  TagManager tm;

  WebSocket webSocket;

  Set<int> newPlayers = new Set();
  Set<int> knownPlayers = new Set();

  RemotePlayerUpdater(this.webSocket)
  : super(Aspect.getAspectForAllOf([Position, Orientation, Controller]));

  @override
  void initialize() {
    webSocket.onMessage.listen((event) {
      var data = JSON.decode(event.data);
      if (data['content'] != null) {
        var content = JSON.decode(data['content']);
        var senderId = data['id'];
        if (knownPlayers.contains(senderId)) {
          var entity = tm.getEntity('$playerTag$senderId');
          var p = pm[entity];
          var o = om[entity];
          p.xyz.x = content['x'];
          p.xyz.y = content['y'];
          o.angle = content['angle'];
        } else {
          if (!knownPlayers.contains(senderId) && content['type'] == 'playerdata') {
            var entity = world
                .createAndAddEntity([new Position(content['x'], content['y']), new Orientation(content['angle'])]);
            knownPlayers.add(senderId);
            tm.register(entity, '$playerTag$senderId');
          }
        }
      }
    });
  }

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var o = om[entity];

    webSocket.send(JSON.encode({'type': 'playerdata', 'x': p.xyz.x, 'y': p.xyz.y, 'angle': o.angle}));

    print('seding ${p.xyz}');
  }
}
