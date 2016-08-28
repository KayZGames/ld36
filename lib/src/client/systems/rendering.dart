part of client;

class PositionRenderingSystem extends EntityProcessingSystem {
  TagManager tm;

  GameStateManager gsm;
  Mapper<Position> pm;
  Mapper<Orientation> om;
  Mapper<SpriteName> sm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  double offsetX;
  double offsetY;

  PositionRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([Position, Orientation, SpriteName]));

  @override
  void begin() {
    var player = tm.getEntity(playerTag);
    if (player == null) {
      offsetX = startX;
      offsetY = startY;
    } else {
      var pp = pm[player];
      offsetX = pp.xyz.x;
      offsetY = pp.xyz.y;
    }
  }

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var o = om[entity];
    var s = sm[entity];
    var sprite = sheet[s.name];

    ctx
      ..save()
      ..translate(p.xyz.x, p.xyz.y)
      ..rotate(o.angle)
      ..drawImageScaledFromSource(
          sheet.image,
          sprite.src.left,
          sprite.src.top,
          sprite.src.width,
          sprite.src.height,
          sprite.dst.left,
          sprite.dst.top,
          sprite.dst.width,
          sprite.dst.height);

//    ctx.strokeStyle = 'red';
//    ctx.strokeRect(-sprite.dst.width/3, -sprite.dst.height/2, sprite.dst.width, sprite.dst.height);
    ctx.restore();
  }
}

class ConnectedClientsRenderer extends VoidEntitySystem {
  GameStateManager gsm;
  CanvasRenderingContext2D ctx;
  WebSocket webSocket;
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

    var countSize = ctx.measureText('${gsm.playerCount}');
    ctx.fillText('${gsm.playerCount}', gsm.width - countSize.width - 10, 16);

    ctx.restore();
  }

  @override
  void initialize() {
    super.initialize();
    webSocket.onMessage.listen((event) {
      try {
        var data = JSON.decode(event.data);
        if (data['type'] == 'clientCount') {
          gsm.playerCount = int.parse(data['message']);
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

class ArenaRenderingSystem extends VoidEntitySystem {
  TagManager tm;
  GameStateManager gsm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  ArenaRenderingSystem(this.ctx, this.sheet) : super();

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
      offsetX -= startX;
      offsetY -= startY;
    }
    ctx
      ..save()
      ..fillStyle = '#4b692f'
      ..fillRect(-offsetX, -offsetY, gsm.width, gsm.height)
      ..restore();
  }
}

class ArenaBorderRenderingSystem extends VoidEntitySystem {
  GameStateManager gsm;
  CanvasRenderingContext2D ctx;
  ArenaBorderRenderingSystem(this.ctx);

  @override
  void processSystem() {
    ctx
      ..save()
      ..strokeStyle = 'darkgrey'
      ..lineWidth = 5
      ..beginPath()
      ..arc(0, 0, gsm.arenaRadius, 0, 2 * PI)
      ..closePath()
      ..stroke()
      ..restore();
  }
}

class CameraPositionResetSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;

  CameraPositionResetSystem(this.ctx);

  @override
  void processSystem() {
    ctx.setTransform(1, 0, 0, 1, 0, 0);
  }
}

class CameraPositioningSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  GameStateManager gsm;
  TagManager tm;

  CanvasRenderingContext2D ctx;

  double offsetX, offsetY;

  CameraPositioningSystem(this.ctx);

  @override
  void begin() {
    offsetX = gsm.width / 2;
    offsetY = gsm.height / 2;
    var player = tm.getEntity(playerTag);
    if (null != player) {
      var p = pm[player];
      offsetX -= p.xyz.x;
      offsetY -= p.xyz.y;
    }
  }

  @override
  void processSystem() {
    ctx.translate(offsetX, offsetY);
  }
}
