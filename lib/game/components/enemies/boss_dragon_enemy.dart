import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class BossDragonEnemy extends BaseEnemy with EnemyMover {
  BossDragonEnemy() : _maxHealth = 1200, super(health: 1200, speed: 50) {
    size = Vector2.all(56);
  }

  final double _maxHealth;
  double _wingPhase = 0;

  @override
  String get spriteKey => 'boss_dragon';

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
    _wingPhase += dt * 6;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = walkSprite;
    if (s != null) {
      s.render(canvas, size: size);
    } else {
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF8B0000));
      final wingSin = sin(_wingPhase);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2 + wingSin * 4),
          width: size.x * 1.4, height: size.y * 0.5,
        ),
        Paint()..color = const Color(0xAACC0000),
      );
      canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.35), 5,
          Paint()..color = const Color(0xFFFF8800));
      canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.35), 5,
          Paint()..color = const Color(0xFFFF8800));
    }
    final hpRatio = (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -10, size.x * hpRatio, 6),
        Paint()..color = const Color(0xFFFF2200));
    canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6),
        Paint()..color = const Color(0xFFFFFFFF)..style = PaintingStyle.stroke);
  }
}
