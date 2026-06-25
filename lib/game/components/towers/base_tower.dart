import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';

/// Base class for all tower types.
abstract class BaseTower extends PositionComponent {
  BaseTower({
    required this.type,
    required this.level,
    required this.attackRange,
    required this.attackDamage,
    required this.attackCooldown,
  });

  final String type;
  final int level;
  final double attackRange;
  final double attackDamage;
  final double attackCooldown;

  double _cooldownRemaining = 0;
  BaseEnemy? _currentTarget;

  @override
  void update(double dt) {
    super.update(dt);

    if (_cooldownRemaining > 0) {
      _cooldownRemaining -= dt;
    }

    _currentTarget = _acquireTarget();
    if (_currentTarget != null && _cooldownRemaining <= 0) {
      _fireAt(_currentTarget!);
      _cooldownRemaining = attackCooldown;
    }
  }

  BaseEnemy? _acquireTarget() {
    final enemies = parent?.children.whereType<BaseEnemy>() ?? const [];
    BaseEnemy? bestTarget;
    var bestProgress = -1.0;

    for (final enemy in enemies) {
      if (!enemy.isAlive) {
        continue;
      }

      final distance = enemy.absoluteCenter.distanceTo(absoluteCenter);
      if (distance > attackRange) {
        continue;
      }

      if (enemy.pathProgress > bestProgress) {
        bestProgress = enemy.pathProgress;
        bestTarget = enemy;
      }
    }

    return bestTarget;
  }

  void _fireAt(BaseEnemy target) {
    onFire(target);
  }

  /// Override in subclasses to apply damage, spawn projectiles, and animate.
  void onFire(BaseEnemy target);
}
