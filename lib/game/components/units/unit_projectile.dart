import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../enemies/base_enemy.dart';

/// A simple flying projectile (arrow or fireball) that moves toward a target
/// enemy, deals damage on contact, and removes itself.
class UnitProjectile extends PositionComponent {
  UnitProjectile({
    required this.target,
    required this.damage,
    required this.assetName,
    required this.projectileSpeed,
    required this.splashRadius,
    required this.color,
    required Vector2 startPosition,
  }) {
    position = startPosition.clone();
    size = Vector2.all(20);
    anchor = Anchor.center;
  }

  final BaseEnemy target;
  final double damage;
  final String assetName;
  final double projectileSpeed;
  /// If > 0, damages all enemies within radius on impact (fireball AoE).
  final double splashRadius;
  final Color color;

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/units/$assetName');
      _sprite = Sprite(img);
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!target.isAlive || target.parent == null) {
      removeFromParent();
      return;
    }

    final dir = (target.absoluteCenter - absoluteCenter);
    final dist = dir.length;

    if (dist <= projectileSpeed * dt + size.x / 2) {
      _impact();
      return;
    }

    dir.normalize();
    position += dir * projectileSpeed * dt;
  }

  void _impact() {
    if (splashRadius > 0) {
      // AoE – damage all enemies in radius.
      final siblings = parent?.children.whereType<BaseEnemy>() ?? const [];
      for (final e in siblings) {
        if (!e.isAlive) continue;
        if (e.absoluteCenter.distanceTo(absoluteCenter) <= splashRadius) {
          e.takeDamage(damage);
        }
      }
    } else {
      target.takeDamage(damage);
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = _sprite;
    if (s != null) {
      s.render(canvas, size: size);
    } else {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        Paint()..color = color,
      );
    }
  }
}
