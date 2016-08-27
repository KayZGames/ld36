part of client;


class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Position> pm;

  WebSocket webSocket;

  InputHandlingSystem(this.webSocket) : super(Aspect.getAspectForAllOf([Controller, Position]));


  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    if (left) {
      p.xyz.x -= 1.0;
    } else if (right) {
      p.xyz.x += 1.0;
    }
    if (up) {
      p.xyz.y -= 1.0;
    } else if (down) {
      p.xyz.y += 1.0;
    }
    webSocket.send(JSON.encode({'type':'pos','x':p.xyz.x,'y':p.xyz.y}));
  }
}

