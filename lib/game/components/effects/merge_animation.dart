import 'dart:ui';

import 'package:flame/components.dart';

/// A brief pulse highlight for a merged tower cell.
class MergeAnimation extends PositionComponent {
  MergeAnimation({required Vector2 position, required this.cellSize}) {
    this.position = position;
    size = Vector2.all(cellSize);
  }

  final double cellSize;

  static const double _duration = 0.4;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    final scale = 1.3 - (progress * 0.3);
    final alpha = ((1.0 - progress) * 180).round();
    final paint = Paint()
      ..color = Color.fromARGB(alpha, 255, 215, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = size / 2;
    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(scale);
    canvas.translate(-center.x, -center.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      paint,
    );
    canvas.restore();
  }
}
