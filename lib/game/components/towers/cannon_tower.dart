import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import '../projectiles/cannonball_projectile.dart';
import 'base_tower.dart';

class CannonTower extends BaseTower {
  CannonTower({int level = 1})
    : super(
        type: 'cannon',
        level: level,
        attackRange: 150.0 + (level * 15.0),
        attackDamage: 40.0 * level,
        attackCooldown: 2.5 - (level * 0.2),
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
    final cannonball = CannonballProjectile.acquire()
      ..configure(damage: attackDamage, splashRadius: 40);
    cannonball.launch(target: target, from: absoluteCenter);
    if (cannonball.parent == null) {
      parent?.add(cannonball);
    }

    _flashTimer = 0.2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final basePaint = Paint()
      ..color = _flashTimer > 0
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF555555);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      basePaint,
    );

    final barrelPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: 36,
        height: 14,
      ),
      barrelPaint,
    );
  }
}
