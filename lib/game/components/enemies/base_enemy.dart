import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import '../grid/grid_board.dart';

/// Base class for all enemy types.
/// Includes pathfinding mixin integration.
abstract class BaseEnemy extends PositionComponent {
  BaseEnemy({required this.health, required this.speed});

  double health;
  double speed;
  double pathProgress = 0;
  bool isAlive = true;

  // Grid movement – populated by WaveManager, consumed by EnemyMover.
  GridBoard? gridBoard;
  (int, int)? entryCell;
  (int, int)? fortCell;

  /// Stateful ticker for the walk animation.
  SpriteAnimationTicker? _walkTicker;

  /// Stateful ticker for the death animation.
  SpriteAnimationTicker? _deathTicker;

  /// Subclasses provide the base filename prefix, e.g. 'goblin'.
  String get spriteKey;

  /// Sprite sheet column count for walk animation. Override per-enemy if different.
  int get walkCols => 3;

  /// Sprite sheet row count for walk animation. Override per-enemy if different.
  int get walkRows => 3;

  /// The current animated walk sprite (null while asset is loading or missing).
  Sprite? get currentWalkSprite => _walkTicker?.getSprite();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final walkAnim = await _loadSheetAnimation(
      '${spriteKey}_walk.png',
      cols: walkCols,
      rows: walkRows,
      stepTime: 0.12,
      loop: true,
    );
    _walkTicker = walkAnim?.createTicker();

    final deathAnim = await _loadSheetAnimation(
      '${spriteKey}_death.png',
      cols: walkCols,
      rows: 1,
      stepTime: 0.10,
      loop: false,
    );
    _deathTicker = deathAnim?.createTicker();
  }

  Future<SpriteAnimation?> _loadSheetAnimation(
    String filename, {
    required int cols,
    required int rows,
    required double stepTime,
    bool loop = true,
  }) async {
    try {
      final img = await Flame.images.load('sprites/enemies/$filename');
      final fw = img.width / cols;
      final fh = img.height / rows;
      final sheet = SpriteSheet(
        image: img,
        srcSize: Vector2(fw.toDouble(), fh.toDouble()),
      );
      final frames = <SpriteAnimationFrame>[
        for (var r = 0; r < rows; r++)
          for (var c = 0; c < cols; c++)
            SpriteAnimationFrame(sheet.getSprite(r, c), stepTime),
      ];
      return SpriteAnimation(frames, loop: loop);
    } catch (_) {
      return null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _walkTicker?.update(dt);
    _deathTicker?.update(dt);
  }

  /// Called after entryCell/fortCell/gridBoard are set to calculate the path.
  void calculatePath() {}

  void takeDamage(double amount) {
    if (!isAlive) {
      return;
    }

    health -= amount;
    if (health <= 0) {
      health = 0;
      isAlive = false;
      removeFromParent();
    }
  }
}
