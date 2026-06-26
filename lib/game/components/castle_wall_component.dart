import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'enemies/base_enemy.dart';
import 'projectiles/arrow_projectile.dart';

/// A castle wall row that spans the full grid width at the 60/40 split line.
///
/// Multiple tower sprites are rendered side-by-side. Only the centre tower
/// (column [cols ~/ 2]) fires arrows at approaching enemies.
class CastleWallComponent extends PositionComponent {
  CastleWallComponent({
    required this.cols,
    required this.cellSize,
    required this.gap,
    required this.maxHp,
  }) : _hp = maxHp;

  final int cols;
  final double cellSize;
  final double gap;
  final int maxHp;

  int _hp;
  double _hitFlash = 0;

  /// Injected by WaveManager so the centre tower can find enemies to shoot.
  List<BaseEnemy> Function()? getEnemies;

  static const double _attackRange = 300.0;
  static const double _attackDamage = 20.0;
  static const double _attackCooldown = 1.8;
  double _cooldownTimer = 0;

  int get hp => _hp;
  int get _centerCol => cols ~/ 2;

  final List<Sprite?> _sprites = [];

  String _spriteForCol(int col) {
    if (col == _centerCol) return 'sprites/towers/archer_tower_l3.png';
    if (col == 0 || col == cols - 1) return 'sprites/towers/magic_tower_l1.png';
    return 'sprites/towers/cannon_tower_l1.png';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (var col = 0; col < cols; col++) {
      try {
        final img = await Flame.images.load(_spriteForCol(col));
        _sprites.add(Sprite(img));
      } catch (_) {
        _sprites.add(null);
      }
    }
  }

  void takeDamage(int amount) {
    _hp = (_hp - amount).clamp(0, maxHp);
    _hitFlash = 0.3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitFlash > 0) {
      _hitFlash = (_hitFlash - dt).clamp(0.0, 0.3);
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

    // Launch from the centre tower slot.
    final stride = cellSize + gap;
    final launchX = _centerCol * stride + cellSize / 2;
    final launchFrom = position + Vector2(launchX, size.y / 2);

    final arrow = ArrowProjectile.acquire()..configure(damage: _attackDamage);
    arrow.launch(target: nearest, from: launchFrom);
    if (arrow.parent == null) {
      parent?.add(arrow);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final stride = cellSize + gap;
    final wallH = size.y;

    // Stone wall background strip.
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF4A3828),
    );

    // Crenellation accent at the top.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 6),
      Paint()..color = const Color(0xFF6A5840),
    );

    // Draw each tower sprite.
    for (var col = 0; col < cols; col++) {
      final x = col * stride;
      final sprite = col < _sprites.length ? _sprites[col] : null;
      if (sprite != null) {
        sprite.render(
          canvas,
          position: Vector2(x + gap, gap),
          size: Vector2(cellSize - gap, wallH - gap * 2),
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(x + gap, gap, cellSize - gap, wallH - gap * 2),
          Paint()..color = const Color(0xFF886633),
        );
      }
    }

    // Hit flash.
    if (_hitFlash > 0) {
      canvas.drawRect(
        size.toRect(),
        Paint()..color = const Color(0x55FF2222),
      );
    }

    // HP bar at bottom.
    final hpRatio = maxHp == 0 ? 0.0 : (_hp / maxHp).clamp(0.0, 1.0);
    final barY = wallH - 8;
    canvas.drawRect(
      Rect.fromLTWH(4, barY, (size.x - 8) * hpRatio, 5),
      Paint()..color = const Color(0xFF00FF44),
    );
    canvas.drawRect(
      Rect.fromLTWH(4, barY, size.x - 8, 5),
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
