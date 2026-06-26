import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../utils/object_pool.dart';
import '../enemies/base_enemy.dart';
import 'base_projectile.dart';

class CannonballProjectile extends BaseProjectile {
  CannonballProjectile._()
    : super(speed: 220, hitbox: CircleHitbox(radius: 6)) {
    size = Vector2.all(12);
  }

  static final ObjectPool<CannonballProjectile> _pool = ObjectPool(
    CannonballProjectile._,
  );

  static CannonballProjectile acquire() => _pool.acquire();

  double _damage = 0;
  double _splashRadius = 40;

  void configure({required double damage, double splashRadius = 40}) {
    _damage = damage;
    _splashRadius = splashRadius;
  }

  @override
  void onHit(BaseEnemy target) {
    final impactPoint = target.absoluteCenter.clone();
    final enemies =
        parent?.children.whereType<BaseEnemy>() ?? const <BaseEnemy>[];

    for (final enemy in enemies) {
      if (!enemy.isAlive) {
        continue;
      }

      if (enemy.absoluteCenter.distanceTo(impactPoint) <= _splashRadius) {
        enemy.takeDamage(_damage);
      }
    }

    despawn();
  }

  @override
  void recycle() => _pool.release(this);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bodyPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, bodyPaint);

    final highlightPaint = Paint()..color = const Color(0xFF666666);
    canvas.drawCircle(const Offset(4, 3), 3, highlightPaint);
  }
}
