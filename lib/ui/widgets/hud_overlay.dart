import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_state.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IgnorePointer(
                child: _HudChip(
                  icon: Icons.waves,
                  label: 'Wave ${state.wave}',
                  color: const Color(0xFF44AAFF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IgnorePointer(
                  child: _FortHpBar(hp: state.fortHp, maxHp: state.fortMaxHp),
                ),
              ),
              const SizedBox(width: 8),
              IgnorePointer(
                child: _HudChip(
                  icon: Icons.monetization_on,
                  label: '${state.gold}',
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 8),
              _SpeedButtons(currentSpeed: state.speed),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FortHpBar extends StatelessWidget {
  const _FortHpBar({required this.hp, required this.maxHp});

  final int hp;
  final int maxHp;

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.5
        ? const Color(0xFF44FF88)
        : ratio > 0.25
        ? Colors.orange
        : Colors.red;

    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Center(
            child: Text(
              'HP $hp / $maxHp',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedButtons extends StatelessWidget {
  const _SpeedButtons({required this.currentSpeed});

  final double currentSpeed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [1.0, 2.0, 3.0].map((speed) {
        final active = currentSpeed == speed;

        return GestureDetector(
          onTap: () => GameState.instance.setSpeed(speed),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFD700) : Colors.black54,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: Text(
              '${speed.toInt()}×',
              style: TextStyle(
                color: active ? Colors.black : const Color(0xFFFFD700),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
