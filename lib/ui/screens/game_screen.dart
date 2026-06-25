import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../game/fort_game.dart';
import 'hud_overlay.dart';

/// Main game screen: hosts the Flame GameWidget with Flutter HUD overlays.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<FortGame>(
        game: FortGame(),
        overlayBuilderMap: {
          'hud': (context, game) => const HudOverlay(),
          // TODO(phase3): Add 'skillSelect' overlay
        },
      ),
    );
  }
}
