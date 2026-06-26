import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class OrcEnemy extends BaseEnemy with EnemyMover {
  OrcEnemy() : _maxHealth = 180, super(health: 180, speed: 60) {
    size = Vector2.all(36);
  }

  final double _maxHealth;

  @override
  String get spriteKey => 'orc';

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
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF556B2F));
      canvas.drawCircle(Offset(6, size.y / 2), 7,
          Paint()..color = const Color(0xFF888888));
      canvas.drawCircle(Offset(size.x - 6, size.y / 2), 7,
          Paint()..color = const Color(0xFF888888));
    }
    final hpRatio = (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x * hpRatio, 4),
        Paint()..color = const Color(0xFF00FF00));
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x, 4),
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke);
  }
}
