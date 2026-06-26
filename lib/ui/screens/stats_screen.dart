import 'package:flutter/material.dart';

import '../../data/persistence_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final persistence = PersistenceService.instance;
    final unlockedSkills = persistence.skillsUnlocked;
    final recentRuns = persistence.runHistory.reversed.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: const Text('Your Fortress Record'),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _StatTile(
            label: 'Highest Wave',
            value: '${persistence.highestWave}',
            icon: '🏆',
          ),
          _StatTile(
            label: 'Total Runs',
            value: '${persistence.totalRuns}',
            icon: '⚔️',
          ),
          _StatTile(
            label: 'Gold Earned (all time)',
            value: '${persistence.totalGoldEarned}',
            icon: '💰',
          ),
          _StatTile(
            label: 'Enemies Slain',
            value: '${persistence.totalEnemiesKilled}',
            icon: '💀',
          ),
          _StatTile(
            label: 'Skills Unlocked',
            value: '${unlockedSkills.length}',
            icon: '✨',
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlocked Skills',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (unlockedSkills.isEmpty)
            const Text(
              'No skills unlocked yet.',
              style: TextStyle(color: Colors.white54),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unlockedSkills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: const Color(0xFF1A1A2E),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          const Text(
            'Recent Runs',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (recentRuns.isEmpty)
            const Text(
              'No run history yet.',
              style: TextStyle(color: Colors.white54),
            )
          else
            ...recentRuns.map(
              (run) => Card(
                color: const Color(0xFF1A1A2E),
                child: ListTile(
                  leading: const Text('⚔️', style: TextStyle(fontSize: 24)),
                  title: Text(
                    'Wave ${run.wavesCompleted}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${run.enemiesKilled} kills · ${run.goldEarned} gold · '
                    '${run.skillsUsed.length} skills',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
