part of client;

class PositionRenderingSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;

  PositionRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];

    ctx
      ..save()
      ..fillStyle = 'red'
      ..translate(gsm.width / 2, gsm.height / 2);

    ctx.fillRect(p.xyz.x, p.xyz.y, 10, 10);
    ctx.restore();
  }
}

class ConnectedClientsRenderer extends VoidEntitySystem {
  GameStateManager gsm;
  CanvasRenderingContext2D ctx;
  WebSocket webSocket;
  int clientCount;
  final String playersOnline = 'Players online:';
  TextMetrics playersOnlineSize;

  ConnectedClientsRenderer(this.ctx, this.webSocket);

  @override
  void processSystem() {
    ctx.save();
    ctx
      ..font = '16px Verdana'
      ..textBaseline = 'top';

    ctx.fillText(playersOnline, gsm.width - playersOnlineSize.width - 60, 16);

    var countSize = ctx.measureText('$clientCount');
    ctx.fillText('$clientCount', gsm.width - countSize.width - 10, 16);

    ctx.restore();
  }

  @override
  void initialize() {
    super.initialize();
    webSocket.onMessage.listen((event) {
      try {
        var data = JSON.decode(event.data);
        if (data['type'] == 'clientCount') {
          this.clientCount = data['message'];
        }
      } catch (e) {}
    });
    webSocket.send('count');
    ctx
      ..save()
      ..font = '16px Verdana'
      ..textBaseline = 'top';
    playersOnlineSize = ctx.measureText(playersOnline);
    ctx.restore();
  }
}
