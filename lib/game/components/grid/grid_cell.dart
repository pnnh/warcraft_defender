import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';

import '../towers/base_tower.dart';

/// A single cell in the defense grid.
class GridCell extends PositionComponent with TapCallbacks {
  GridCell({
    required this.row,
    required this.col,
    required this.cellSize,
    this.isLocked = false,
    this.onTap,
  }) : super(size: Vector2.all(cellSize));

  static const Color _buildBorderColor = Color(0x44AAAAAA);
  static const Color _occupiedFillColor = Color(0x221AFF1A);
  static const Color _occupiedBorderColor = Color(0x8844AA44);
  static const Color _ghostValidFillColor = Color(0x6633D1FF);
  static const Color _ghostValidBorderColor = Color(0xFF7FE7FF);
  static const Color _ghostInvalidFillColor = Color(0x66FF5A5A);
  static const Color _ghostInvalidBorderColor = Color(0xFFFF9B9B);

  final int row;
  final int col;
  final double cellSize;
  final void Function(GridCell)? onTap;

  /// True for combat-zone and castle-wall rows – no building allowed here.
  final bool isLocked;

  bool isOccupied = false;
  bool isGhosted = false;
  bool isGhostValid = true;
  BaseTower? occupyingTower;

  static Sprite? _tileSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (_tileSprite == null) {
      try {
        final img = await Flame.images.load('tilemaps/grid_tile.png');
        _tileSprite = Sprite(img);
      } catch (_) {}
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();
    final tile = _tileSprite;

    // Always render the tile texture as the base layer.
    if (tile != null) {
      tile.render(canvas, size: size);
    }

    if (isGhosted) {
      final ghostFillPaint = Paint()
        ..color = isGhostValid ? _ghostValidFillColor : _ghostInvalidFillColor;
      final ghostBorderPaint = Paint()
        ..color = isGhostValid ? _ghostValidBorderColor : _ghostInvalidBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect, ghostFillPaint);
      canvas.drawRect(rect, ghostBorderPaint);
      return;
    }

    if (isLocked) {
      // Combat zone: subtle dark vignette, no build border
      canvas.drawRect(rect, Paint()..color = const Color(0x33000000));
      return;
    }

    // Building zone: thin border to show placeable cells
    if (isOccupied) {
      canvas.drawRect(rect, Paint()..color = _occupiedFillColor);
      canvas.drawRect(
        rect,
        Paint()
          ..color = _occupiedBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else {
      canvas.drawRect(
        rect,
        Paint()
          ..color = _buildBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isLocked) {
      onTap?.call(this);
    }
    super.onTapDown(event);
  }
}
