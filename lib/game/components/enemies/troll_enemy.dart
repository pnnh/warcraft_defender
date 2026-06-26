import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class TrollEnemy extends BaseEnemy with EnemyMover {
  TrollEnemy() : _maxHealth = 320, super(health: 320, speed: 40) {
    size = Vector2.all(44);
  }

  final double _maxHealth;

  @override
  String get spriteKey => 'troll';

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = walkSprite;
    if (s != null) {
      s.render(canvas, size: size);
    } else {
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF8B4513));
      canvas.drawRect(Rect.fromLTWH(size.x - 8, 4, 10, size.y - 8),
          Paint()..color = const Color(0xFF6B3A2A));
    }
    final hpRatio = (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x * hpRatio, 4),
        Paint()..color = const Color(0xFF00FF00));
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x, 4),
        Paint()..color = const Color(0xFF333333)..style = PaintingStyle.stroke);
  }
}
