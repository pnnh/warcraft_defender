import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'enemies/base_enemy.dart';
import 'projectiles/arrow_projectile.dart';

class FortComponent extends PositionComponent {
  FortComponent({required this.maxHp}) : _hp = maxHp {
    size = Vector2.all(80);
  }

  final int maxHp;
  int _hp;
  double _hitFlash = 0;
  Sprite? _fortSprite;

  /// Injected by WaveManager so the fort can find enemies to shoot.
  List<BaseEnemy> Function()? getEnemies;

  static const double _attackRange = 210.0;
  static const double _attackDamage = 20.0;
  static const double _attackCooldown = 1.8;
  double _cooldownTimer = 0;

  int get hp => _hp;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/ui/fort_sprite.png');
      _fortSprite = Sprite(img);
    } catch (_) {}
  }

  void takeDamage(int amount) {
    _hp = (_hp - amount).clamp(0, maxHp);
    _hitFlash = 0.3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitFlash > 0) {
      _hitFlash = (_hitFlash - dt).clamp(0, 0.3);
    }
    _tickAttack(dt);
  }

  void _tickAttack(double dt) {
    _cooldownTimer -= dt;
    if (_cooldownTimer > 0) return;

    final enemies = getEnemies?.call() ?? const [];
    BaseEnemy? nearest;
    var nearestDist = double.infinity;
    for (final enemy in enemies) {
      if (!enemy.isAlive) continue;
      final dist = enemy.absoluteCenter.distanceTo(absoluteCenter);
      if (dist <= _attackRange && dist < nearestDist) {
        nearestDist = dist;
        nearest = enemy;
      }
    }
    if (nearest == null) return;

    _cooldownTimer = _attackCooldown;
    final arrow = ArrowProjectile.acquire()..configure(damage: _attackDamage);
    arrow.launch(target: nearest, from: position + size * 0.5);
    if (arrow.parent == null) {
      parent?.add(arrow);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final sprite = _fortSprite;
    if (sprite != null) {
      if (_hitFlash > 0) {
        // Red tint overlay on hit
        sprite.render(canvas, size: size);
        canvas.drawRect(size.toRect(),
            Paint()..color = const Color(0x88FF0000));
      } else {
        sprite.render(canvas, size: size);
      }
    } else {
      final color = _hitFlash > 0
          ? const Color(0xFFFF4444)
          : const Color(0xFF886633);
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
        Paint()..color = color,
      );
    }

    final hpRatio = maxHp == 0 ? 0.0 : (_hp / maxHp).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(4, size.y - 10, (size.x - 8) * hpRatio, 6),
      Paint()..color = const Color(0xFF00FF44),
    );
    canvas.drawRect(
      Rect.fromLTWH(4, size.y - 10, size.x - 8, 6),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke,
    );
  }
}
