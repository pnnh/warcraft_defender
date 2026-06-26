class AStarPathfinder {
  AStarPathfinder({required this.rows, required this.cols});

  final int rows;
  final int cols;

  List<(int, int)> findPath(
    (int, int) start,
    (int, int) goal,
    bool Function(int row, int col) isBlocked,
  ) {
    if (!_isWithinBounds(start) || !_isWithinBounds(goal)) {
      return const [];
    }

    if (start == goal) {
      return const [];
    }

    final openSet = <_ScoredNode>[
      _ScoredNode(position: start, fScore: _heuristic(start, goal)),
    ];
    final cameFrom = <(int, int), (int, int)>{};
    final gScore = <(int, int), int>{start: 0};
    final closedSet = <(int, int)>{};

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => a.compareTo(b));
      final current = openSet.removeAt(0).position;

      if (!closedSet.add(current)) {
        continue;
      }

      if (current == goal) {
        return _reconstructPath(cameFrom, current);
      }

      for (final neighbor in _neighbors(current, goal, isBlocked)) {
        if (closedSet.contains(neighbor)) {
          continue;
        }

        final tentativeGScore = (gScore[current] ?? 0) + 1;
        if (tentativeGScore >= (gScore[neighbor] ?? 1 << 30)) {
          continue;
        }

        cameFrom[neighbor] = current;
        gScore[neighbor] = tentativeGScore;
        openSet.add(
          _ScoredNode(
            position: neighbor,
            fScore: tentativeGScore + _heuristic(neighbor, goal),
          ),
        );
      }
    }

    return const [];
  }

  int _heuristic((int, int) a, (int, int) b) {
    return (a.$1 - b.$1).abs() + (a.$2 - b.$2).abs();
  }

  bool _isWithinBounds((int, int) position) {
    final (row, col) = position;
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  Iterable<(int, int)> _neighbors(
    (int, int) position,
    (int, int) goal,
    bool Function(int row, int col) isBlocked,
  ) sync* {
    final (row, col) = position;
    const directions = <(int, int)>[(-1, 0), (0, 1), (1, 0), (0, -1)];

    for (final (deltaRow, deltaCol) in directions) {
      final next = (row + deltaRow, col + deltaCol);
      if (!_isWithinBounds(next)) {
        continue;
      }

      if (next != goal && isBlocked(next.$1, next.$2)) {
        continue;
      }

      yield next;
    }
  }

  List<(int, int)> _reconstructPath(
    Map<(int, int), (int, int)> cameFrom,
    (int, int) current,
  ) {
    final path = <(int, int)>[current];
    var cursor = current;

    while (cameFrom.containsKey(cursor)) {
      cursor = cameFrom[cursor]!;
      path.add(cursor);
    }

    return path.reversed.skip(1).toList(growable: false);
  }
}

class _ScoredNode {
  const _ScoredNode({required this.position, required this.fScore});

  final (int, int) position;
  final int fScore;

  int compareTo(_ScoredNode other) {
    final scoreComparison = fScore.compareTo(other.fScore);
    if (scoreComparison != 0) {
      return scoreComparison;
    }

    if (position.$1 != other.position.$1) {
      return position.$1.compareTo(other.position.$1);
    }

    return position.$2.compareTo(other.position.$2);
  }
}
