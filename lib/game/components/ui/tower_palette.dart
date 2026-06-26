import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';

enum TowerType { archer, cannon, magic }

class TowerPaletteEntry {
  const TowerPaletteEntry({
    required this.type,
    required this.label,
    required this.cost,
    required this.fillColor,
    required this.accentColor,
  });

  final TowerType type;
  final String label;
  final int cost;
  final Color fillColor;
  final Color accentColor;

  String get id => switch (type) {
    TowerType.archer => 'archer',
    TowerType.cannon => 'cannon',
    TowerType.magic => 'magic',
  };
}

typedef TowerDragStartCallback =
    void Function(TowerPaletteEntry entry, Vector2 canvasPosition);
typedef TowerDragUpdateCallback = void Function(Vector2 canvasPosition);
typedef TowerDragEndCallback =
    void Function(TowerPaletteEntry entry, Vector2 canvasPosition);
typedef TowerDragCancelCallback = void Function();

class TowerPalette extends PositionComponent {
  TowerPalette({
    required this.currentGold,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  static const List<TowerPaletteEntry> items = [
    TowerPaletteEntry(
      type: TowerType.archer,
      label: '弓箭手',
      cost: 50,
      fillColor: Color(0xFF2E6B2E),
      accentColor: Color(0xFF88FF44),
    ),
    TowerPaletteEntry(
      type: TowerType.cannon,
      label: '剑士',
      cost: 80,
      fillColor: Color(0xFF1A3A6A),
      accentColor: Color(0xFF88CCFF),
    ),
    TowerPaletteEntry(
      type: TowerType.magic,
      label: '法师',
      cost: 120,
      fillColor: Color(0xFF6A2D91),
      accentColor: Color(0xFFCC88FF),
    ),
  ];

  final int Function() currentGold;
  final TowerDragStartCallback onDragStart;
  final TowerDragUpdateCallback onDragUpdate;
  final TowerDragEndCallback onDragEnd;
  final TowerDragCancelCallback onDragCancel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const itemWidth = 88.0;
    const itemHeight = 90.0;
    const gap = 12.0;

    for (var i = 0; i < items.length; i++) {
      final item = TowerPaletteItem(
        entry: items[i],
        currentGold: currentGold,
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onDragCancel: onDragCancel,
      )
        ..size = Vector2(itemWidth, itemHeight)
        ..position = Vector2(i * (itemWidth + gap), 0);
      await add(item);
    }

    size = Vector2(
      (items.length * itemWidth) + ((items.length - 1) * gap),
      itemHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = const Color(0xCC111111);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20),
        const Radius.circular(14),
      ),
      backgroundPaint,
    );

    super.render(canvas);
  }
}

class TowerPaletteItem extends PositionComponent with DragCallbacks {
  TowerPaletteItem({
    required this.entry,
    required this.currentGold,
    required TowerDragStartCallback onDragStart,
    required TowerDragUpdateCallback onDragUpdate,
    required TowerDragEndCallback onDragEnd,
    required TowerDragCancelCallback onDragCancel,
  }) : _handleDragStart = onDragStart,
       _handleDragUpdate = onDragUpdate,
       _handleDragEnd = onDragEnd,
       _handleDragCancel = onDragCancel;

  static final TextPaint _labelPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );
  static final TextPaint _costPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFE082),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
  static final TextPaint _lockedPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF8A80),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  final TowerPaletteEntry entry;
  final int Function() currentGold;
  final TowerDragStartCallback _handleDragStart;
  final TowerDragUpdateCallback _handleDragUpdate;
  final TowerDragEndCallback _handleDragEnd;
  final TowerDragCancelCallback _handleDragCancel;

  Vector2 _lastCanvasPosition = Vector2.zero();

  bool get _canAfford => currentGold() >= entry.cost;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final affordable = _canAfford;
    final backgroundColor = isDragged
        ? const Color(0xFF24384A)
        : affordable
            ? const Color(0xFF2E2E2E)
            : const Color(0xFF1D1D1D);
    final borderColor = isDragged
        ? const Color(0xFF8BE9FD)
        : affordable
            ? entry.accentColor
            : const Color(0xFF666666);
    final iconFillColor = affordable
        ? entry.fillColor
        : entry.fillColor.withAlpha(115);
    final iconAccentColor = affordable
        ? entry.accentColor
        : entry.accentColor.withAlpha(115);
    final cardRect = size.toRect();

    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(10)),
      Paint()..color = backgroundColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(10)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _labelPaint.render(
      canvas,
      entry.label,
      Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
    );

    final iconRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2 - 2),
      width: 34,
      height: 34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(iconRect, const Radius.circular(6)),
      Paint()..color = iconFillColor,
    );
    canvas.drawCircle(iconRect.center, 6, Paint()..color = iconAccentColor);

    final goldText = '${entry.cost}g';
    (affordable ? _costPaint : _lockedPaint).render(
      canvas,
      goldText,
      Vector2(size.x / 2, size.y - 22),
      anchor: Anchor.topCenter,
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!_canAfford) {
      return;
    }

    super.onDragStart(event);
    _lastCanvasPosition = event.canvasPosition.clone();
    _handleDragStart(entry, _lastCanvasPosition.clone());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_canAfford || !isDragged) {
      return;
    }

    _lastCanvasPosition = event.canvasEndPosition.clone();
    _handleDragUpdate(_lastCanvasPosition.clone());
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!isDragged) {
      return;
    }

    final dropPosition = _lastCanvasPosition.clone();
    super.onDragEnd(event);
    _handleDragEnd(entry, dropPosition);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (!isDragged) {
      return;
    }

    super.onDragCancel(event);
    _handleDragCancel();
  }
}
