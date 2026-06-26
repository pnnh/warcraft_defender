import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.wavesReached,
    required this.goldEarned,
    required this.onRetry,
    required this.onMenu,
  });

  final int wavesReached;
  final int goldEarned;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0000),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade800, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💀', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(
                'FORT FALLEN',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              _StatRow(
                label: 'Waves Survived',
                value: '$wavesReached',
                icon: '🌊',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: 'Gold Earned',
                value: '$goldEarned',
                icon: '💰',
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _GameButton(
                      label: '🔄 Retry',
                      color: const Color(0xFF004400),
                      borderColor: Colors.green,
                      onTap: onRetry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GameButton(
                      label: '🏠 Menu',
                      color: const Color(0xFF000044),
                      borderColor: Colors.blue,
                      onTap: onMenu,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({
    super.key,
    required this.goldEarned,
    required this.onRetry,
    required this.onMenu,
  });

  final int goldEarned;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF001A00),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(
                'VICTORY!',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All 20 waves defeated!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              _StatRow(label: 'Total Gold', value: '$goldEarned', icon: '💰'),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _GameButton(
                      label: '🔄 Play Again',
                      color: const Color(0xFF004400),
                      borderColor: const Color(0xFFFFD700),
                      onTap: onRetry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GameButton(
                      label: '🏠 Menu',
                      color: const Color(0xFF000044),
                      borderColor: Colors.blue,
                      onTap: onMenu,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 15),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
