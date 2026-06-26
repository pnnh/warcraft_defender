import 'dart:ui';

import 'package:flame/components.dart';

import 'grid_cell.dart';

/// Represents the defense grid board.
/// Manages cells, placement, and merge interactions.
class GridBoard extends PositionComponent {
  GridBoard({
    this.rows = 8,
    this.cols = 5,
    this.cellSize = 64.0,
    /// Rows 0..lockRows (inclusive) are locked – combat zone + castle row.
    /// Building is only allowed in rows > lockRows.
    this.lockRows = 0,
    this.onCellTap,
  }) {
    cells = List.generate(rows, (row) {
      return List.generate(cols, (col) {
        return GridCell(
          row: row,
          col: col,
          cellSize: cellSize,
          isLocked: row <= lockRows,
          onTap: (cell) => onCellTap?.call(cell),
        )
          ..position = Vector2(col * (cellSize + gap), row * (cellSize + gap));
      });
    });
    size = Vector2(cols * (cellSize + gap), rows * (cellSize + gap));
  }

  final int rows;
  final int cols;
  final double cellSize;
  final double gap = 2.0;

  /// Number of rows from the top that belong to the combat zone.
  /// Row [lockRows] is the castle wall row (also locked).
  /// Building is allowed in rows [lockRows + 1] to [rows - 1].
  final int lockRows;

  final void Function(GridCell)? onCellTap;

  late final List<List<GridCell>> cells;
  GridCell? _ghostCell;

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
    if (!occupied) {
      cell.occupyingTower = null;
    }
  }

  GridCell? cellAtCanvasPosition(Vector2 canvasPosition) {
    final localPosition = canvasPosition - position;
    if (localPosition.x < 0 ||
        localPosition.y < 0 ||
        localPosition.x >= size.x ||
        localPosition.y >= size.y) {
      return null;
    }

    final stride = cellSize + gap;
    final col = (localPosition.x / stride).floor();
    final row = (localPosition.y / stride).floor();
    final cellOffsetX = localPosition.x - (col * stride);
    final cellOffsetY = localPosition.y - (row * stride);
    if (cellOffsetX > cellSize || cellOffsetY > cellSize) {
      return null;
    }

    return cellAt(row, col);
  }

  void setGhostCell(GridCell? cell, {required bool isValid}) {
    if (_ghostCell == cell && cell?.isGhostValid == isValid) {
      return;
    }

    clearGhostCell();
    if (cell == null) {
      return;
    }

    cell.isGhosted = true;
    cell.isGhostValid = isValid;
    _ghostCell = cell;
  }

  void clearGhostCell() {
    if (_ghostCell == null) {
      return;
    }

    _ghostCell!
      ..isGhosted = false
      ..isGhostValid = true;
    _ghostCell = null;
  }

  @override
  void render(Canvas canvas) {
    // No background panel – individual cells provide the tiled texture.
    super.render(canvas);
  }
}
