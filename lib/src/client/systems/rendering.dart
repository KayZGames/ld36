part of client;

class PositionRenderingSystem extends EntityProcessingSystem {
  TagManager tm;

  GameStateManager gsm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;

  PositionRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var player = tm.getEntity(playerTag);
    var pp = pm[player];

    ctx
      ..save()
      ..fillStyle = 'red'
      ..translate(gsm.width / 2, gsm.height / 2);

    ctx.fillRect(p.xyz.x - pp.xyz.x, p.xyz.y - pp.xyz.y, 10, 10);
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

class TrackRenderingSystem extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  TrackRenderingSystem(this.ctx, this.sheet) : super();

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];

    var t = sheet['track01'];
    ctx
      ..save()
      ..translate(-p.xyz.x, -p.xyz.y)
      ..drawImageScaledFromSource(sheet.image, t.src.left, t.src.top,
          t.src.width, t.src.height, 0, 0, t.dst.width, t.dst.height)
      ..restore();
  }
}
