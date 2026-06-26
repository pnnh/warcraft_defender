import 'dart:math' as math;

import 'package:flame/components.dart';

import '../grid/grid_board.dart';
import '../../../utils/astar_pathfinding.dart';
import 'base_enemy.dart';

/// Mixin that gives a [BaseEnemy] the ability to follow a grid-based A* path.
mixin EnemyMover on BaseEnemy {
  // gridBoard, entryCell, fortCell are declared in BaseEnemy

  final List<(int, int)> _path = <(int, int)>[];
  int _pathIndex = 0;
  int? _occupancySignature;

  double distanceTraveled = 0;

  // Natural walking wobble — each enemy gets its own random frequency, amplitude, and phase.
  final double _wobbleFreq = 0.9 + math.Random().nextDouble() * 0.8;   // 0.9–1.7 cycles/s
  final double _wobbleAmp = 0.15 + math.Random().nextDouble() * 0.12;  // 0.15–0.27 lateral fraction
  final double _wobblePhase = math.Random().nextDouble() * math.pi * 2;
  double _wobbleTimer = 0;

  @override
  void calculatePath() {
    final board = gridBoard;
    if (board == null) {
      _clearPath();
      return;
    }

    final goal = fortCell ?? _defaultGoalCell(board);
    final start = _currentCell(board) ?? entryCell ?? _defaultEntryCell(board);
    final pathfinder = AStarPathfinder(rows: board.rows, cols: board.cols);
    final nextPath = pathfinder.findPath(start, goal, (row, col) {
      final cell = board.cellAt(row, col);
      return cell?.isOccupied ?? true;
    });

    _path
      ..clear()
      ..addAll(nextPath);
    _pathIndex = 0;
    _occupancySignature = _buildOccupancySignature(board);
  }

  void updateMovement(double dt) {
    if (isAttackingFort) return;

    final board = gridBoard;
    if (board == null) {
      return;
    }

    if (_occupancySignature != _buildOccupancySignature(board)) {
      calculatePath();
    }

    if (_path.isEmpty || _pathIndex >= _path.length) {
      return;
    }

    final target = _path[_pathIndex];
    final worldTarget = _cellCenter(board, target.$1, target.$2);
    final offset = worldTarget - absolutePosition;
    final distance = offset.length;
    final step = speed * dt;

    if (distance <= step) {
      position += offset;
      distanceTraveled += distance;
      _pathIndex += 1;
      return;
    }

    _wobbleTimer += dt;
    final dir = offset / distance;
    // Perpendicular direction (rotate 90°) for lateral sway.
    final perp = Vector2(-dir.y, dir.x);
    final sway = math.sin(_wobbleTimer * _wobbleFreq * math.pi * 2 + _wobblePhase) * _wobbleAmp;
    final wobblyDir = (dir + perp * sway)..normalize();
    position += wobblyDir * step;
    distanceTraveled += step;
  }

  Vector2 _cellCenter(GridBoard board, int row, int col) {
    return board.absolutePosition +
        Vector2(
          col * (board.cellSize + board.gap) + (board.cellSize / 2),
          row * (board.cellSize + board.gap) + (board.cellSize / 2),
        );
  }

  (int, int)? _currentCell(GridBoard board) {
    final localPosition = absolutePosition - board.absolutePosition;
    final stride = board.cellSize + board.gap;
    final col = (localPosition.x / stride).floor();
    final row = (localPosition.y / stride).floor();
    final candidate = (row, col);

    if (_isWithinBoard(board, candidate)) {
      return candidate;
    }

    return null;
  }

  // Portrait mode: enemies enter from the top-center, exit at the bottom-center.
  (int, int) _defaultEntryCell(GridBoard board) {
    return (0, board.cols ~/ 2);
  }

  (int, int) _defaultGoalCell(GridBoard board) {
    return (board.rows - 1, board.cols ~/ 2);
  }

  int _buildOccupancySignature(GridBoard board) {
    var signature = 17;
    for (var row = 0; row < board.rows; row += 1) {
      for (var col = 0; col < board.cols; col += 1) {
        signature =
            (signature * 31) ^
            (board.cellAt(row, col)?.isOccupied == true ? 1 : 0);
      }
    }
    return signature;
  }

  bool _isWithinBoard(GridBoard board, (int, int) cell) {
    return cell.$1 >= 0 &&
        cell.$1 < board.rows &&
        cell.$2 >= 0 &&
        cell.$2 < board.cols;
  }

  void _clearPath() {
    _path.clear();
    _pathIndex = 0;
    _occupancySignature = null;
  }
}
