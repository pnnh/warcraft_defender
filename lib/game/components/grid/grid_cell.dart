import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

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

  final int row;
  final int col;
  final double cellSize;
  final void Function(GridCell)? onTap;

  bool isOccupied = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();
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

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call(this);
    super.onTapDown(event);
  }
}
