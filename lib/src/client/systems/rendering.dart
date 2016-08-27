part of client;

class PositionRenderingSystem extends EntityProcessingSystem {
  TagManager tm;

  GameStateManager gsm;
  Mapper<Position> pm;
  Mapper<Orientation> om;

  CanvasRenderingContext2D ctx;

  final int size = 20;

  PositionRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([Position, Orientation]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var o = om[entity];
    var player = tm.getEntity(playerTag);
    var pp = pm[player];

    ctx
      ..save()
      ..fillStyle = 'red'
      ..translate(gsm.width / 2 - pp.xyz.x - size / 2 + p.xyz.x,
          gsm.height / 2 - pp.xyz.y - size / 2 + p.xyz.y)
      ..arc(0, 0, size / 2, 0, 2 * PI)
      ..fill()
      ..strokeStyle = 'blue'
      ..lineWidth = 2
      ..beginPath()
      ..moveTo(0, 0)
      ..lineTo(cos(o.angle) * size / 2, sin(o.angle) * size / 2)
      ..closePath()
      ..stroke();
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
  GameStateManager gsm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  TrackRenderingSystem(this.ctx, this.sheet) : super();

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var offsetX = gsm.width / 2;
    var offsetY = gsm.height / 2;
    if (player != null) {
      var p = pm[player];
      offsetX += -p.xyz.x;
      offsetY += -p.xyz.y;
    } else {
      offsetX += 550.0;
      offsetY += 190.0;
    }

    var t = sheet['track01'];
    ctx
      ..save()
      ..translate(offsetX, offsetY)
      ..drawImageScaledFromSource(sheet.image, t.src.left, t.src.top,
          t.src.width, t.src.height, 0, 0, t.dst.width, t.dst.height)
      ..restore();
  }
}
