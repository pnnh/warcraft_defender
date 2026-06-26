import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import '../../systems/skill_system.dart';

/// Base class for all tower types.
abstract class BaseTower extends PositionComponent implements SkillTarget {
  BaseTower({
    required this.type,
    required this.level,
    required this.attackRange,
    required this.attackDamage,
    required this.attackCooldown,
  }) {
    SkillSystem.instance.applyBuffsToTarget(this);
  }

  @override
  final String type;
  final int level;
  @override
  double attackRange;
  @override
  double attackDamage;
  @override
  double attackCooldown;
  @override
  double critChance = 0.0;
  @override
  double splashRadiusBonus = 0.0;
  @override
  int bonusProjectiles = 0;
  @override
  int chainTargetBonus = 0;
  @override
  double slowEffectStrength = 0.0;
  @override
  double splashDamageMultiplier = 0.0;

  double _cooldownRemaining = 0;
  BaseEnemy? _currentTarget;

  void buffDamage(double fraction) {
    attackDamage *= 1 + fraction;
  }

  void buffRange(double fraction) {
    attackRange *= 1 + fraction;
  }

  void buffCooldown(double fraction) {
    attackCooldown = (attackCooldown * (1 + fraction))
        .clamp(0.1, double.infinity)
        .toDouble();
  }

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
