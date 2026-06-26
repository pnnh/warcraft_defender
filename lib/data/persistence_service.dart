import 'package:hive_flutter/hive_flutter.dart';

/// Handles all persistent storage for meta-progression.
class PersistenceService {
  PersistenceService._();

  static final PersistenceService instance = PersistenceService._();

  static const String _boxName = 'meta_progression';
  static const String _keyHighestWave = 'highest_wave';
  static const String _keyTotalGoldEarned = 'total_gold_earned';
  static const String _keyTotalRuns = 'total_runs';
  static const String _keyTotalEnemiesKilled = 'total_enemies_killed';
  static const String _keySkillsUnlocked = 'skills_unlocked';
  static const String _keyRunHistory = 'run_history';

  late final Box<dynamic> _box;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
    _initialized = true;
  }

  int get highestWave => _box.get(_keyHighestWave, defaultValue: 0) as int;

  int get totalGoldEarned =>
      _box.get(_keyTotalGoldEarned, defaultValue: 0) as int;

  int get totalRuns => _box.get(_keyTotalRuns, defaultValue: 0) as int;

  int get totalEnemiesKilled =>
      _box.get(_keyTotalEnemiesKilled, defaultValue: 0) as int;

  List<String> get skillsUnlocked =>
      List<String>.from(_box.get(_keySkillsUnlocked, defaultValue: <String>[]));

  List<RunRecord> get runHistory {
    final raw = _box.get(_keyRunHistory, defaultValue: <dynamic>[]) as List;
    return raw
        .map(
          (entry) => RunRecord.fromMap(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  bool isSkillUnlocked(String skillId) => skillsUnlocked.contains(skillId);

  Future<void> unlockSkill(String skillId) => unlockSkills(<String>[skillId]);

  Future<void> unlockSkills(Iterable<String> skillIds) async {
    final updatedSkills = <String>{...skillsUnlocked, ...skillIds};
    await _box.put(_keySkillsUnlocked, updatedSkills.toList()..sort());
  }

  Future<void> recordRunCompletion({
    required int wavesCompleted,
    required int goldEarned,
    required int enemiesKilled,
    required List<String> skillsUsed,
  }) async {
    if (wavesCompleted > highestWave) {
      await _box.put(_keyHighestWave, wavesCompleted);
    }
    await _box.put(_keyTotalGoldEarned, totalGoldEarned + goldEarned);
    await _box.put(_keyTotalRuns, totalRuns + 1);
    await _box.put(_keyTotalEnemiesKilled, totalEnemiesKilled + enemiesKilled);

    final history = runHistory;
    history.add(
      RunRecord(
        wavesCompleted: wavesCompleted,
        goldEarned: goldEarned,
        enemiesKilled: enemiesKilled,
        skillsUsed: List<String>.from(skillsUsed),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (history.length > 20) {
      history.removeAt(0);
    }

    await _box.put(
      _keyRunHistory,
      history.map((record) => record.toMap()).toList(),
    );
  }

  Future<void> clearAll() async => _box.clear();
}

class RunRecord {
  const RunRecord({
    required this.wavesCompleted,
    required this.goldEarned,
    required this.enemiesKilled,
    required this.skillsUsed,
    required this.timestamp,
  });

  final int wavesCompleted;
  final int goldEarned;
  final int enemiesKilled;
  final List<String> skillsUsed;
  final int timestamp;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'wavesCompleted': wavesCompleted,
    'goldEarned': goldEarned,
    'enemiesKilled': enemiesKilled,
    'skillsUsed': skillsUsed,
    'timestamp': timestamp,
  };

  factory RunRecord.fromMap(Map<String, dynamic> map) => RunRecord(
    wavesCompleted: (map['wavesCompleted'] as int?) ?? 0,
    goldEarned: (map['goldEarned'] as int?) ?? 0,
    enemiesKilled: (map['enemiesKilled'] as int?) ?? 0,
    skillsUsed: List<String>.from(map['skillsUsed'] as List? ?? const []),
    timestamp: (map['timestamp'] as int?) ?? 0,
  );
}
