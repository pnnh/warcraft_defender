import 'package:flame/components.dart';

/// Base class for all tower types.
abstract class BaseTower extends PositionComponent {
  final int level;
  final String type;

  BaseTower({required this.type, required this.level});

  // TODO(phase2): Implement attack range, target acquisition, and firing logic
}
