import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import '../enemies/base_enemy.dart';

/// Callback that returns all currently-alive enemies in the game world.
typedef EnemyQueryCallback = List<BaseEnemy> Function();

/// Abstract base for player-controlled friendly units spawned by towers.
/// Units move toward the nearest enemy and attack at intervals.
abstract class BaseUnit extends PositionComponent {
  BaseUnit({
    required this.maxHealth,
    required this.damage,
    required this.attackRange,
    required this.attackCooldown,
    required this.getEnemies,
  }) : health = maxHealth;

  final double maxHealth;
  double health;
  final double damage;
  final double attackRange;
  final double attackCooldown;
  final EnemyQueryCallback getEnemies;

  static const double speed = 80.0;

  /// Sprite sheet frame count (3×3 default, same as enemies).
  int get walkCols => 3;
  int get walkRows => 3;

  /// Asset filename without path prefix, e.g. 'archer_unit_walk.png'.
  String get walkAsset;

  /// Fall-back fill color used when the sprite is not yet loaded.
  Color get fallbackColor;

  SpriteAnimationTicker? _walkTicker;
  BaseEnemy? _target;
  double _attackTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/units/$walkAsset');
      final fw = img.width / walkCols;
      final fh = img.height / walkRows;
      final sheet = SpriteSheet(
        image: img,
        srcSize: Vector2(fw.toDouble(), fh.toDouble()),
      );
      final frames = <SpriteAnimationFrame>[
        for (var r = 0; r < walkRows; r++)
          for (var c = 0; c < walkCols; c++)
            SpriteAnimationFrame(sheet.getSprite(r, c), 0.12),
      ];
      _walkTicker = SpriteAnimation(frames, loop: true).createTicker();
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (health <= 0) {
      removeFromParent();
      return;
    }

    _walkTicker?.update(dt);
    _attackTimer -= dt;

    // Refresh target every tick (enemies may have died or moved).
    _target = _pickTarget();

    final target = _target;
    if (target == null) return;

    final dist = target.absoluteCenter.distanceTo(absoluteCenter);

    if (dist <= attackRange) {
      // In range – stop moving and attack.
      if (_attackTimer <= 0) {
        performAttack(target);
        _attackTimer = attackCooldown;
      }
    } else {
      // Move toward target.
      final dir = (target.absoluteCenter - absoluteCenter).normalized();
      position += dir * speed * dt;
    }
  }

  BaseEnemy? _pickTarget() {
    BaseEnemy? best;
    var bestDist = double.infinity;
    for (final e in getEnemies()) {
      if (!e.isAlive) continue;
      final d = e.absoluteCenter.distanceTo(absoluteCenter);
      if (d < bestDist) {
        bestDist = d;
        best = e;
      }
    }
    return best;
  }

  /// Subclasses implement attack behaviour (spawn projectile or deal damage).
  void performAttack(BaseEnemy target);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final frame = _walkTicker?.getSprite();
    if (frame != null) {
      frame.render(canvas, size: size);
    } else {
      canvas.drawOval(size.toRect(), Paint()..color = fallbackColor);
    }

    // HP bar
    final hpRatio = (health / maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, -7, size.x * hpRatio, 4),
      Paint()..color = const Color(0xFF44FF44),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -7, size.x, 4),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke,
    );
  }
}
