import 'dart:convert';
import 'package:ld36/client.dart';

Game game;
int gamepadIndex;
WebSocket webSocket;

Future<Null> main() async {
  webSocket = new WebSocket('wss://isowosi.com/ws/bc/ld36-preview');

  webSocket.onMessage.listen((event) {
    try {
      var data = JSON.decode(event.data);
      if (data['type'] == 'clientCount') {
        querySelector('#playersOnline').text = 'Players online: ${data['message']}';
      }
    } catch (e) {}
  });
  webSocket.onOpen.listen((event) async {
    game = await new Game(webSocket).start();
    querySelector('#loading').style.display = 'none';
    (querySelector('#startGame') as ButtonElement)
      ..style.display = 'inline-block';
    querySelector('#startGame').onClick.listen((_) {
      if (!game.isPlayerAlive()) {
        startGame();
      }
    });
    querySelector('body').onKeyDown.listen((event) {
      if (!game.isPlayerAlive() && event.keyCode == KeyCode.ENTER) {
        startGame();
      }
    });
    window.on['gamepadconnected'].listen((GamepadEvent event) {
      gamepadIndex = event.gamepad.index;
    });
    window.requestAnimationFrame(handleGamepads);
  });
}

void handleGamepads(_) {
  if (!game.isPlayerAlive() && gamepadIndex != null) {
    var gamepad = window.navigator.getGamepads()[gamepadIndex];
    if (gamepad.buttons[0].pressed || gamepad.buttons[9].pressed) {
      startGame();
    }
  }
  window.requestAnimationFrame(handleGamepads);
}

Future<Null> startGame() async {
  game = await new Game(webSocket).start();
  game.gamepadIndex = gamepadIndex;
  querySelector('#storyContainer').style..opacity = '0.0';
  querySelector('body').style.cursor = 'none';
  querySelector('#game').style.opacity = '1.0';
  querySelector('#hud').style.opacity = '1.0';

  await new Future.delayed(new Duration(seconds: 1));
  game.spawnPlayer();
  querySelector('#storyContainer').style.display = 'none';
  game.onGameOver().then((score) {
    querySelector('#storyContainer').style
      ..opacity = '1.0'
      ..display = 'flex'
      ..cursor = 'inherit';
    querySelector('#game').style.opacity = '0.5';
    querySelector('#hud').style.opacity = '0.5';
    querySelector('body').style.cursor = 'inherit';
  });
}
