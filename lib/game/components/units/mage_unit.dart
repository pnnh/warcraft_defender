import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import 'base_unit.dart';
import 'unit_projectile.dart';

/// Friendly mage unit. Casts fireballs that explode in a small AoE.
/// High damage, medium range, slow attack.
class MageUnit extends BaseUnit {
  MageUnit({required super.getEnemies})
    : super(
        maxHealth: 60,
        damage: 55,
        attackRange: 130,
        attackCooldown: 2.0,
      ) {
    size = Vector2.all(28);
    anchor = Anchor.center;
  }

  @override
  String get walkAsset => 'mage_unit_walk.png';

  @override
  Color get fallbackColor => const Color(0xFFAA44FF);

  @override
  void performAttack(BaseEnemy target) {
    parent?.add(
      UnitProjectile(
        target: target,
        damage: damage,
        assetName: 'fireball.png',
        projectileSpeed: 200,
        splashRadius: 48, // AoE fireball
        color: const Color(0xFFFF6600),
        startPosition: absoluteCenter,
      ),
    );
  }
}
