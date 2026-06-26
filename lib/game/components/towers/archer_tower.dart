import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import '../projectiles/arrow_projectile.dart';
import 'base_tower.dart';

class ArcherTower extends BaseTower {
  ArcherTower({
    this.towerType = 'archer',
    this.fillColor = const Color(0xFF8B4513),
    this.accentColor = const Color(0xFFFFD700),
    super.level = 1,
  }) : super(
         type: towerType,
         attackRange: 180,
         attackDamage: 15,
         attackCooldown: 1.2,
       );

  final String towerType;
  final Color fillColor;
  final Color accentColor;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bodyPaint = Paint()..color = fillColor;
    final tipPaint = Paint()..color = accentColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      bodyPaint,
    );
    canvas.drawCircle(size.toRect().center, size.x * 0.18, tipPaint);
  }

  @override
  void onFire(BaseEnemy target) {
    final arrow = ArrowProjectile.acquire()..configure(damage: attackDamage);
    arrow.launch(target: target, from: absoluteCenter);
    if (arrow.parent == null) {
      parent?.add(arrow);
    }
  }
}
