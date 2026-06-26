import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class OrcEnemy extends BaseEnemy with EnemyMover {
  OrcEnemy() : super(health: 180, speed: 60) {
    size = Vector2.all(36);
  }

  @override
  String get spriteKey => 'orc';

  @override
  double get fortAttackDamage => 15.0;

  @override
  double get fortAttackInterval => 1.5;

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
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF556B2F));
      canvas.drawCircle(Offset(6, size.y / 2), 7,
          Paint()..color = const Color(0xFF888888));
      canvas.drawCircle(Offset(size.x - 6, size.y / 2), 7,
          Paint()..color = const Color(0xFF888888));
    }
    // HP bar hidden intentionally.
  }
}
