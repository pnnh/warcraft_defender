import 'package:flame/components.dart';

/// Base class for all enemy types.
/// Includes pathfinding mixin integration.
abstract class BaseEnemy extends PositionComponent {
  BaseEnemy({required this.health, required this.speed});

  double health;
  double speed;
  double pathProgress = 0;
  bool isAlive = true;

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
