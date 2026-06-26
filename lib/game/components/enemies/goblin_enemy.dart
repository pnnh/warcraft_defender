import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class GoblinEnemy extends BaseEnemy with EnemyMover {
  GoblinEnemy() : _maxHealth = 80, super(health: 80, speed: 80) {
    size = Vector2.all(32);
  }

  final double _maxHealth;

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bodyPaint = Paint()..color = const Color(0xFF22AA22);
    canvas.drawOval(size.toRect(), bodyPaint);

    final hpRatio = (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, -8, size.x * hpRatio, 4),
      Paint()..color = const Color(0xFF00FF00),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -8, size.x, 4),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke,
    );
  }
}
