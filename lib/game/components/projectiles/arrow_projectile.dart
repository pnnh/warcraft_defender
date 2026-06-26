import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../utils/object_pool.dart';
import '../enemies/base_enemy.dart';
import 'base_projectile.dart';

class ArrowProjectile extends BaseProjectile {
  ArrowProjectile._()
    : super(speed: 320, hitbox: RectangleHitbox(size: Vector2(16, 4))) {
    size = Vector2(16, 4);
  }

  static final ObjectPool<ArrowProjectile> _pool = ObjectPool(
    ArrowProjectile._,
  );

  static ArrowProjectile acquire() => _pool.acquire();

  double _damage = 0;

  void configure({required double damage}) {
    _damage = damage;
  }

  @override
  void onHit(BaseEnemy target) {
    target.takeDamage(_damage);
    despawn();
  }

  @override
  void recycle() => _pool.release(this);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final shaftPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(size.toRect(), shaftPaint);

    final tipPaint = Paint()..color = const Color(0xFFCCCCCC);
    canvas.drawRect(const Rect.fromLTWH(12, 1, 4, 2), tipPaint);
  }
}
