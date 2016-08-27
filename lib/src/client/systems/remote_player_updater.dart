part of client;

class RemotePlayerUpdater extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Orientation> om;
  TagManager tm;

  WebSocket webSocket;

  List<int> playersToRemove = new List<int>();
  Set<int> knownPlayers = new Set();

  RemotePlayerUpdater(this.webSocket)
      : super(Aspect.getAspectForAllOf([Position, Orientation, Controller]));

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
    if (content['type'] == 'playerdata') {
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
            new Orientation(content['angle'])
          ]);
          knownPlayers.add(senderId);
          tm.register(entity, '$playerTag$senderId');
        }
      }
    }
  }

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var o = om[entity];

    webSocket.send(JSON.encode(
        {'type': 'playerdata', 'x': p.xyz.x, 'y': p.xyz.y, 'angle': o.angle}));

    playersToRemove
        .map((playerId) => tm.getEntity('$playerTag$playerId'))
        .where((entity) => entity != null)
        .forEach((entity) {
      entity.deleteFromWorld();
    });
    playersToRemove.clear();
  }
}
