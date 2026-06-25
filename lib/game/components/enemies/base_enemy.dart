import 'package:flame/components.dart';

/// Base class for all enemy types.
/// Includes pathfinding mixin integration.
abstract class BaseEnemy extends PositionComponent {
  double health;
  double speed;

  BaseEnemy({required this.health, required this.speed});

  // TODO(phase2): Implement A* pathfinding movement toward the fort
}
