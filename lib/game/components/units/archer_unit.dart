import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import 'base_unit.dart';
import 'unit_projectile.dart';

/// Friendly archer unit. Fires arrows at enemies from a distance.
/// Low damage, long range, fast attack.
class ArcherUnit extends BaseUnit {
  ArcherUnit({required super.getEnemies})
    : super(
        maxHealth: 80,
        damage: 15,
        attackRange: 160,
        attackCooldown: 1.2,
      ) {
    size = Vector2.all(36);
    anchor = Anchor.center;
  }

  @override
  String get walkAsset => 'archer_unit_walk.png';

  @override
  Color get fallbackColor => const Color(0xFF44BB44);

  @override
  void performAttack(BaseEnemy target) {
    parent?.add(
      UnitProjectile(
        target: target,
        damage: damage,
        assetName: 'arrow.png',
        projectileSpeed: 300,
        splashRadius: 0,
        color: const Color(0xFFFFD700),
        startPosition: position + size * 0.5,
      ),
    );
  }
}
