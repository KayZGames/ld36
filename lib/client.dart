library client;

import 'dart:web_gl';
import 'dart:html';
export 'dart:html';
import 'package:ld36/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;
  int gamepadIndex;

  Game() : super.noAssets('ld36', '#game', 800, 600, webgl: true) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '16px Verdana';

    world.addManager(new GameStateManager());

    handleResize(window.innerWidth, window.innerHeight);
    window.onResize
        .listen((_) => handleResize(window.innerWidth, window.innerHeight));
  }
  void createEntities() {
    // addEntity([Component1, Component2]);
  }
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new WebGlCanvasCleaningSystem(ctx),
        new CanvasCleaningSystem(hudCanvas),
        new FpsRenderingSystem(hudCtx, fillStyle: 'white'),
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

