import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import 'base_tower.dart';

class ArcherTower extends BaseTower {
  ArcherTower({int level = 1})
    : super(
        type: 'archer',
        level: level,
        attackRange: 180.0 + (level * 20.0),
        attackDamage: 15.0 * level,
        attackCooldown: 1.2 - (level * 0.1),
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
    target.takeDamage(attackDamage);
    _flashTimer = 0.15;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final basePaint = Paint()
      ..color = _flashTimer > 0
          ? const Color(0xFFFFAA00)
          : const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      basePaint,
    );

    final tipPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, tipPaint);
  }
}
