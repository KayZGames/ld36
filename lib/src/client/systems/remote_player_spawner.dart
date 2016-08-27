part of client;

class RemotePlayerUpdater extends VoidEntitySystem {
  Mapper<Position> pm;
  TagManager tm;

  WebSocket webSocket;
  RemotePlayerUpdater(this.webSocket);
  Set<int> newPlayers = new Set();
  Set<int> knownPlayers = new Set();

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
          p.xyz.x = content['x'];
          p.xyz.y = content['y'];
        } else {
          if (!knownPlayers.contains(senderId) && content['type'] == 'pos') {
            var entity = world
                .createAndAddEntity([new Position(content['x'], content['y'])]);
            knownPlayers.add(senderId);
            tm.register(entity, '$playerTag$senderId');
          }
        }
      }
    });
  }

  @override
  void processSystem() {}
}
