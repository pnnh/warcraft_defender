import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class GoblinEnemy extends BaseEnemy with EnemyMover {
  GoblinEnemy() : super(health: 80, speed: 80) {
    size = Vector2.all(32);
  }

  @override
  String get spriteKey => 'goblin';

  @override
  double get fortAttackDamage => 8.0;

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = currentWalkSprite;
    if (s != null) {
      s.render(canvas, size: size);
    } else {
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF22AA22));
    }
    // HP bar hidden intentionally.
  }
}
