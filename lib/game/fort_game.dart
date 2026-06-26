import 'dart:ui';

import 'package:flame/components.dart' show HasTimeScale;
import 'package:flame/game.dart';

import 'game_state.dart';
import 'audio/audio_manager.dart';
import 'components/grid/grid_board.dart';
import 'components/grid/grid_cell.dart';
import 'components/towers/archer_tower.dart';
import 'components/ui/tower_palette.dart';

/// Main FlameGame entry point for Fort Guardian.
/// Orchestrates all game systems: grid, waves, skills, and combat.
class FortGame extends FlameGame with HasTimeScale {
  static const int startingGold = 150;

  late final GridBoard _grid;
  late final TowerPalette _towerPalette;

  _DragPlacementState? _dragPlacement;
  int gold = startingGold;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.instance.initialize();
    await AudioManager.instance.onGameplayStart();

    _grid = GridBoard();
    _towerPalette = TowerPalette(
      currentGold: () => gold,
      onDragStart: _handleTowerDragStart,
      onDragUpdate: _handleTowerDragUpdate,
      onDragEnd: _handleTowerDragEnd,
      onDragCancel: _cancelTowerDrag,
    );

    await add(_grid);
    await add(_towerPalette);
    _positionComponents();
    GameState.instance.addListener(() {
      timeScale = GameState.instance.speed;
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      _positionComponents();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    final ghostSize = _grid.cellSize * 0.68;
    final ghostRect = Rect.fromCenter(
      center: Offset(
        dragPlacement.canvasPosition.x,
        dragPlacement.canvasPosition.y,
      ),
      width: ghostSize,
      height: ghostSize,
    );
    final ghostFillPaint = Paint()
      ..color = dragPlacement.entry.fillColor.withAlpha(150);
    final ghostBorderPaint = Paint()
      ..color = dragPlacement.isValidDrop
          ? dragPlacement.entry.accentColor
          : const Color(0xFFFF8A80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(ghostRect, const Radius.circular(8)),
      ghostFillPaint,
    );
    canvas.drawCircle(
      ghostRect.center,
      ghostSize * 0.18,
      Paint()..color = dragPlacement.entry.accentColor.withAlpha(200),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ghostRect, const Radius.circular(8)),
      ghostBorderPaint,
    );
  }

  void _positionComponents() {
    final paletteX = (size.x - _towerPalette.size.x) / 2;
    final paletteY = size.y - _towerPalette.size.y - 24;
    final maxGridY = (paletteY - _grid.size.y - 24).clamp(24.0, double.infinity);
    final centeredGridY = ((paletteY - _grid.size.y) / 2).clamp(
      24.0,
      maxGridY,
    );

    _grid.position = Vector2(
      (size.x - _grid.size.x) / 2,
      centeredGridY.toDouble(),
    );
    _towerPalette.position = Vector2(paletteX, paletteY);
  }

  void _handleTowerDragStart(TowerPaletteEntry entry, Vector2 canvasPosition) {
    _dragPlacement = _DragPlacementState(
      entry: entry,
      canvasPosition: canvasPosition.clone(),
      isValidDrop: false,
    );
    _updateGhostState(canvasPosition);
  }

  void _handleTowerDragUpdate(Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    dragPlacement.canvasPosition = canvasPosition.clone();
    _updateGhostState(canvasPosition);
  }

  void _handleTowerDragEnd(TowerPaletteEntry entry, Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    dragPlacement.canvasPosition = canvasPosition.clone();
    final targetCell = _grid.cellAtCanvasPosition(canvasPosition);
    final canPlace =
        targetCell != null &&
        !targetCell.isOccupied &&
        gold >= dragPlacement.entry.cost;

    if (canPlace) {
      _placeTower(targetCell, entry);
      gold -= dragPlacement.entry.cost;
    }

    _clearDragPlacement();
  }

  void _cancelTowerDrag() {
    _clearDragPlacement();
  }

  void _updateGhostState(Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      _grid.clearGhostCell();
      return;
    }

    final targetCell = _grid.cellAtCanvasPosition(canvasPosition);
    final isValidDrop =
        targetCell != null &&
        !targetCell.isOccupied &&
        gold >= dragPlacement.entry.cost;

    dragPlacement.isValidDrop = isValidDrop;
    _grid.setGhostCell(targetCell, isValid: isValidDrop);
  }

  void _placeTower(GridCell cell, TowerPaletteEntry entry) {
    _grid.setOccupied(cell.row, cell.col, true);

    final towerSize = _grid.cellSize * 0.72;
    final tower = ArcherTower(
      towerType: entry.id,
      fillColor: entry.fillColor,
      accentColor: entry.accentColor,
    )
      ..size = Vector2.all(towerSize)
      ..position = cell.position + Vector2.all((_grid.cellSize - towerSize) / 2);

    _grid.add(tower);
  }

  void _clearDragPlacement() {
    _grid.clearGhostCell();
    _dragPlacement = null;
  }
}

class _DragPlacementState {
  _DragPlacementState({
    required this.entry,
    required this.canvasPosition,
    required this.isValidDrop,
  });

  final TowerPaletteEntry entry;
  Vector2 canvasPosition;
  bool isValidDrop;
}
