import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../grid/grid_board.dart';

/// Base class for all enemy types.
/// Includes pathfinding mixin integration.
abstract class BaseEnemy extends PositionComponent {
  BaseEnemy({required this.health, required this.speed});

  double health;
  double speed;
  double pathProgress = 0;
  bool isAlive = true;

  // Grid movement – populated by WaveManager, consumed by EnemyMover.
  GridBoard? gridBoard;
  (int, int)? entryCell;
  (int, int)? fortCell;

  /// Sprite shown while the enemy is alive and walking.
  Sprite? walkSprite;

  /// Sprite shown for a brief moment on death before removal.
  Sprite? deathSprite;

  /// Subclasses provide the base filename prefix, e.g. 'goblin'.
  String get spriteKey;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final walkImg =
          await Flame.images.load('sprites/enemies/${spriteKey}_walk.png');
      walkSprite = Sprite(walkImg);
    } catch (_) {}
    try {
      final deathImg =
          await Flame.images.load('sprites/enemies/${spriteKey}_death.png');
      deathSprite = Sprite(deathImg);
    } catch (_) {}
  }

  /// Called after entryCell/fortCell/gridBoard are set to calculate the path.
  void calculatePath() {}

  void takeDamage(double amount) {
    if (!isAlive) {
      return;
    }

    health -= amount;
    if (health <= 0) {
      health = 0;
      isAlive = false;
      removeFromParent();
    }
  }
}
