import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class TrollEnemy extends BaseEnemy with EnemyMover {
  TrollEnemy() : super(health: 320, speed: 40) {
    size = Vector2.all(44);
  }

  @override
  String get spriteKey => 'troll';

  @override
  double get fortAttackDamage => 25.0;

  @override
  double get fortAttackInterval => 2.0;

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
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF8B4513));
      canvas.drawRect(Rect.fromLTWH(size.x - 8, 4, 10, size.y - 8),
          Paint()..color = const Color(0xFF6B3A2A));
    }
    // HP bar hidden intentionally.
  }
}
