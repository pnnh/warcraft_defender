import 'dart:ui';

import 'package:flame/components.dart';

import 'grid_cell.dart';

/// Represents the defense grid board.
/// Manages cells, placement, and merge interactions.
class GridBoard extends PositionComponent {
  GridBoard({this.rows = 6, this.cols = 8, this.cellSize = 64.0}) {
    cells = List.generate(rows, (row) {
      return List.generate(cols, (col) {
        return GridCell(row: row, col: col, cellSize: cellSize)
          ..position = Vector2(col * (cellSize + gap), row * (cellSize + gap));
      });
    });
    size = Vector2(cols * (cellSize + gap), rows * (cellSize + gap));
  }

  final int rows;
  final int cols;
  final double cellSize;
  final double gap = 2.0;

  late final List<List<GridCell>> cells;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll(cells.expand((row) => row));
  }

  GridCell? cellAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }

    return cells[row][col];
  }

  void setOccupied(int row, int col, bool occupied) {
    final cell = cellAt(row, col);
    if (cell == null) {
      return;
    }

    cell.isOccupied = occupied;
  }

  @override
  void render(Canvas canvas) {
    final panelPaint = Paint()
      ..color = const Color(0xAA101010)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      panelPaint,
    );

    super.render(canvas);
  }
}
