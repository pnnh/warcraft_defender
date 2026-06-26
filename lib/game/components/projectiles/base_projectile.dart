import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../enemies/base_enemy.dart';

abstract class BaseProjectile extends PositionComponent
    with CollisionCallbacks {
  BaseProjectile({required this.speed, required this._hitbox}) {
    anchor = Anchor.center;
    add(_hitbox);
    _setActive(false);
  }

  static final Expando<RectangleHitbox> _enemyHitboxes =
      Expando<RectangleHitbox>('enemyHitbox');

  final double speed;
  final ShapeHitbox _hitbox;

  BaseEnemy? _target;
  bool _active = false;

  void Function(BaseProjectile projectile)? onRelease;

  @protected
  BaseEnemy? get target => _target;

  @protected
  bool get isActive => _active;

  void launch({required BaseEnemy target, required Vector2 from}) {
    _ensureEnemyHitbox(target);
    _target = target;
    position = from.clone();
    _setActive(true);
    _faceTarget(target.absoluteCenter);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_active) {
      return;
    }

    final currentTarget = _target;
    if (currentTarget == null ||
        !currentTarget.isAlive ||
        currentTarget.parent == null) {
      onMiss();
      return;
    }

    final toTarget = currentTarget.absoluteCenter - absoluteCenter;
    final distance = toTarget.length;
    if (distance == 0) {
      onHit(currentTarget);
      return;
    }

    final step = speed * dt;
    final direction = toTarget / distance;
    _faceTarget(currentTarget.absoluteCenter);
    position += direction * math.min(step, distance);

    if (distance <= step) {
      onHit(currentTarget);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_active) {
      return;
    }

    super.render(canvas);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!_active) {
      return;
    }

    final otherTarget = switch (other) {
      BaseEnemy enemy => enemy,
      _ when other.parent is BaseEnemy => other.parent! as BaseEnemy,
      _ => null,
    };
    if (otherTarget == null || !otherTarget.isAlive) {
      return;
    }

    if (_target != null && otherTarget != _target) {
      return;
    }

    onHit(otherTarget);
  }

  @protected
  void despawn() {
    if (!_active) {
      return;
    }

    _target = null;
    _setActive(false);
    _release();
  }

  void onHit(BaseEnemy target);

  void onMiss() => despawn();

  void recycle();

  void _release() {
    final release = onRelease;
    if (release != null) {
      release(this);
      return;
    }

    recycle();
  }

  void _setActive(bool value) {
    _active = value;
    _hitbox.collisionType = value
        ? CollisionType.active
        : CollisionType.inactive;

    if (!value) {
      position.setValues(-1000, -1000);
      angle = 0;
    }
  }

  void _faceTarget(Vector2 targetPosition) {
    final direction = targetPosition - absoluteCenter;
    angle = math.atan2(direction.y, direction.x);
  }

  void _ensureEnemyHitbox(BaseEnemy enemy) {
    if (_enemyHitboxes[enemy] != null) {
      return;
    }

    final hitbox = RectangleHitbox(
      size: enemy.size.clone(),
      collisionType: CollisionType.passive,
    );
    _enemyHitboxes[enemy] = hitbox;
    enemy.add(hitbox);
  }
}
