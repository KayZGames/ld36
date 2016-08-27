library client;

import 'dart:convert';
import 'dart:web_gl';
import 'dart:html';
export 'dart:html';
import 'package:ld36/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';
part 'src/client/systems/remote_player_updater.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;
  int gamepadIndex;
  WebSocket webSocket;

  Game(this.webSocket)
      : super('ld36', '#game', 800, 600, webgl: true, bodyDefsName: null) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '30px Verdana';

    world.addManager(new GameStateManager());
    world.addManager(new TagManager());
    world.addManager(new GroupManager());

    handleResize(window.innerWidth, window.innerHeight);
    window.onResize
        .listen((_) => handleResize(window.innerWidth, window.innerHeight));
  }

  @override
  void createEntities() {
//    addEntity([new Position(0.0, 0.0), new Controller()]);
  }

  void spawnPlayer() {
    var x = startX;
    var y = startY;
    var player = addEntity([
      new Position(x, y),
      new Acceleration(),
      new Brake(),
      new Velocity(0.0, 0.0),
      new Orientation(0.0),
      new Controller(),
      new SpriteName('chariot'),
    ]);
    var tm = world.getManager(TagManager) as TagManager;
    tm.register(player, playerTag);
    webSocket.send(JSON.encode({'type': 'addPlayer', 'x': x, 'y': y}));
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new InputHandlingSystem(webSocket),
        new AccelerationSystem(),
        new BrakeSystem(),
        new MovementSystem(),
        new WebGlCanvasCleaningSystem(ctx),
        new CanvasCleaningSystem(hudCanvas),
        new TrackRenderingSystem(hudCtx, spriteSheet),
//        new FpsRenderingSystem(hudCtx, fillStyle: 'white'),
        new PositionRenderingSystem(hudCtx, spriteSheet),
        new ConnectedClientsRenderer(hudCtx, webSocket),
        new ArrowHitDetectionSystem(),
        new LifetimeExpirationSystem(),
        new RemotePlayerUpdater(webSocket),
        new SingleTransmissionSystem(),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(600, height);
    resizeCanvas(canvas, width, height);
    resizeCanvas(hudCanvas, width, height);
    (ctx as RenderingContext).viewport(0, 0, width, height);
    (world.getManager(GameStateManager) as GameStateManager)
      ..width = width
      ..height = height;
  }

  void resizeCanvas(CanvasElement canvas, int width, int height) {
    canvas.width = width;
    canvas.height = height;
    canvas.style.width = '${width}px';
    canvas.style.height = '${height}px';
  }

  Future<int> onGameOver() {
    var gsm = world.getManager(GameStateManager) as GameStateManager;
    return gsm.onGameOver();
  }
}
