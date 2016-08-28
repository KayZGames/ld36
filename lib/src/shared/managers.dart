part of shared;

class GameStateManager extends Manager {
  int width, height;
  var _completer = new Completer<int>();
  int playerCount = 1;

  double _arenaRadius = 500.0;

  double get arenaRadius => max(_arenaRadius, 500.0);
  set arenaRadius(double value) => _arenaRadius = value;

  Future<int> onGameOver() {
    return _completer.future;
  }

  void gameOver(int score) {
    _completer.complete(score);
  }
}

