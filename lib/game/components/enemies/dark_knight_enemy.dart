import 'dart:ui';

import 'package:flame/components.dart';

import 'base_enemy.dart';
import 'enemy_mover.dart';

class DarkKnightEnemy extends BaseEnemy with EnemyMover {
  DarkKnightEnemy() : _maxHealth = 250, super(health: 250, speed: 90) {
    size = Vector2.all(34);
  }

  final double _maxHealth;

  @override
  String get spriteKey => 'dark_knight';

  @override
  double get fortAttackDamage => 20.0;

  @override
  double get fortAttackInterval => 1.2;

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
      canvas.drawOval(size.toRect(), Paint()..color = const Color(0xFF1A1A1A));
      canvas.drawRect(Rect.fromLTWH(size.x * 0.2, size.y * 0.3, size.x * 0.6, 4),
          Paint()..color = const Color(0xFFFF4400));
    }
    final hpRatio = (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x * hpRatio, 4),
        Paint()..color = const Color(0xFF00BBFF));
    canvas.drawRect(Rect.fromLTWH(0, -8, size.x, 4),
        Paint()..color = const Color(0xFF333333)..style = PaintingStyle.stroke);
  }
}
