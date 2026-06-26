import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import '../units/base_unit.dart';
import '../units/mage_unit.dart';
import 'base_tower.dart';

class MagicTower extends BaseTower {
  MagicTower({super.level = 1})
    : super(
        type: 'magic',
        attackRange: 200.0 + (level * 25.0),
        attackDamage: 25.0 * level,
        attackCooldown: 1.8 - (level * 0.1),
      ) {
    size = Vector2.all(56);
  }

  double _flashTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
  }

  @override
  void onFire(BaseEnemy target) {
    final enemies = parent?.children.whereType<BaseEnemy>() ?? const [];
    final chainedTargets = <BaseEnemy>[target];

    for (final enemy in enemies) {
      if (!enemy.isAlive || enemy == target) {
        continue;
      }

      final distance = enemy.absoluteCenter.distanceTo(target.absoluteCenter);
      if (distance <= 80) {
        chainedTargets.add(enemy);
        if (chainedTargets.length >= 3) {
          break;
        }
      }
    }

    for (final enemy in chainedTargets) {
      enemy.takeDamage(attackDamage);
    }

    _flashTimer = 0.15;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = sprite;
    if (s != null) {
      s.render(canvas, size: size);
      return;
    }
    // Geometry fallback
    final basePaint = Paint()
      ..color = _flashTimer > 0
          ? const Color(0xFFAA88FF)
          : const Color(0xFF440088);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      basePaint,
    );
    final orbPaint = Paint()..color = const Color(0xFFBB66FF);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 12, orbPaint);
    for (var i = 0; i < level && i < 5; i++) {
      canvas.drawCircle(
        Offset(6.0 + (i * 10.0), size.y - 8),
        3,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
  }

  @override
  BaseUnit? createUnit(EnemyQueryCallback getEnemies) =>
      MageUnit(getEnemies: getEnemies);
}
