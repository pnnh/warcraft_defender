import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import 'base_unit.dart';

/// Friendly sword warrior unit. Charges into melee range and slashes enemies.
/// Medium damage, short range, moderate attack speed.
class SwordUnit extends BaseUnit {
  SwordUnit({required super.getEnemies})
    : super(
        maxHealth: 150,
        damage: 30,
        attackRange: 36,
        attackCooldown: 0.9,
      ) {
    size = Vector2.all(30);
    anchor = Anchor.center;
  }

  @override
  String get walkAsset => 'sword_unit_walk.png';

  @override
  Color get fallbackColor => const Color(0xFF4488FF);

  @override
  void performAttack(BaseEnemy target) {
    // Melee: direct instant damage.
    target.takeDamage(damage);
    // Visual flash – briefly tint the target (handled by target's own render).
  }
}
