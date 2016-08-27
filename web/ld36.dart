import 'dart:convert';
import 'package:ld36/client.dart';

Game game;
int gamepadIndex;
WebSocket webSocket;

Future<Null> main() async {
  webSocket = new WebSocket('ws://192.168.178.35:8081/ws/bc/ld36');

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
    game.stop();
    querySelector('#loading').style.display = 'none';
    (querySelector('#startGame') as ButtonElement)
      ..style.display = 'inline-block';
    querySelector('#startGame').onClick.listen((_) {
      if (game.isStopped) {
        startGame();
      }
    });
    querySelector('body').onKeyDown.listen((event) {
      if (game.isStopped && event.keyCode == KeyCode.ENTER) {
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
  if (game.isStopped && gamepadIndex != null) {
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
  game.pause();
  querySelector('#storyContainer').style..opacity = '0.0';
  querySelector('body').style.cursor = 'none';
  querySelector('#game').style.opacity = '1.0';
  querySelector('#hud').style.opacity = '1.0';

  await new Future.delayed(new Duration(seconds: 1));
  game.resume();
  game.spawnPlayer();
  querySelector('#storyContainer').style.display = 'none';
  game.onGameOver().then((score) {
    game.stop();
    querySelector('#lastscore').text = '$score';
    if (int.parse(querySelector('#highscore').text) < score) {
      querySelector('#highscore').text = '$score';
    }
    querySelector('#storyContainer').style
      ..opacity = '1.0'
      ..display = 'flex'
      ..cursor = 'inherit';
    querySelector('#game').style.opacity = '0.1';
    querySelector('#hud').style.opacity = '0.1';
    querySelector('body').style.cursor = 'inherit';
  });
}
