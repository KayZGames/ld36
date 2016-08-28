part of shared;

class GameStateManager extends Manager {
  int width, height;
  StreamController<int> _completer = new StreamController<int>();
  int playerCount = 1;

  double _arenaRadius = 500.0;

  double get arenaRadius => max(_arenaRadius, 500.0);
  set arenaRadius(double value) => _arenaRadius = value;

  Stream<int> onGameOver() {
    return _completer.stream;
  }

  void gameOver(int score) {
    _completer.add(score);
  }
}

