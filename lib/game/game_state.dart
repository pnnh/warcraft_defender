import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  GameState._();

  static final GameState instance = GameState._();

  int _wave = 0;
  int _fortHp = 100;
  int _fortMaxHp = 100;
  int _gold = 150;
  double _speed = 1.0;

  int get wave => _wave;
  int get fortHp => _fortHp;
  int get fortMaxHp => _fortMaxHp;
  int get gold => _gold;
  double get speed => _speed;

  void updateWave(int wave) {
    _wave = wave;
    notifyListeners();
  }

  void updateFortHp(int hp, {int? maxHp}) {
    _fortHp = hp;
    if (maxHp != null) {
      _fortMaxHp = maxHp;
    }
    notifyListeners();
  }

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (_gold < amount) {
      return false;
    }

    _gold -= amount;
    notifyListeners();
    return true;
  }

  void setSpeed(double speed) {
    _speed = speed;
    notifyListeners();
  }
}
