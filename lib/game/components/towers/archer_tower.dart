import 'dart:ui';

import 'package:flame/components.dart';

import '../enemies/base_enemy.dart';
import '../projectiles/arrow_projectile.dart';
import '../units/base_unit.dart';
import '../units/archer_unit.dart';
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
    final s = sprite;
    if (s != null) {
      s.render(canvas, size: size);
      return;
    }
    // Geometry fallback
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
    // Use parent-local center so the arrow is in the same coordinate space as its parent (GridBoard).
    arrow.launch(target: target, from: position + size * 0.5);
    if (arrow.parent == null) {
      parent?.add(arrow);
    }
  }

  @override
  BaseUnit? createUnit(EnemyQueryCallback getEnemies) =>
      ArcherUnit(getEnemies: getEnemies);
}
