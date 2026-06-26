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
    this.onTap,
  }) : super(size: Vector2.all(cellSize));

  static const Color _emptyFillColor = Color(0xFF3A3A3A);
  static const Color _emptyBorderColor = Color(0xFF555555);
  static const Color _occupiedFillColor = Color(0xFF1A3A1A);
  static const Color _occupiedBorderColor = Color(0xFF44AA44);
  static const Color _ghostValidFillColor = Color(0x6633D1FF);
  static const Color _ghostValidBorderColor = Color(0xFF7FE7FF);
  static const Color _ghostInvalidFillColor = Color(0x66FF5A5A);
  static const Color _ghostInvalidBorderColor = Color(0xFFFF9B9B);

  final int row;
  final int col;
  final double cellSize;
  final void Function(GridCell)? onTap;

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
    if (tile != null && !isGhosted) {
      tile.render(canvas, size: size);
      if (isOccupied) {
        canvas.drawRect(rect,
            Paint()..color = const Color(0x441AFF1A)..style = PaintingStyle.fill);
      }
    } else {
      final fillPaint = Paint()
        ..color = isOccupied ? _occupiedFillColor : _emptyFillColor
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = isOccupied ? _occupiedBorderColor : _emptyBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }

    if (isGhosted) {
      final ghostFillPaint = Paint()
        ..color = isGhostValid ? _ghostValidFillColor : _ghostInvalidFillColor
        ..style = PaintingStyle.fill;
      final ghostBorderPaint = Paint()
        ..color =
            isGhostValid ? _ghostValidBorderColor : _ghostInvalidBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect, ghostFillPaint);
      canvas.drawRect(rect, ghostBorderPaint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call(this);
    super.onTapDown(event);
  }
}
