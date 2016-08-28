part of shared;

class GameStateManager extends Manager {
  int width, height;
  var _completer = new Completer<int>();
  int playerCount = 1;

  double arenaRadius = 500.0;

  Future<int> onGameOver() {
    return _completer.future;
  }

  void gameOver(int score) {
    _completer.complete(score);
  }
}

