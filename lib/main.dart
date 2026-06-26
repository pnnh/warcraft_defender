import 'package:flutter/material.dart';
import 'data/persistence_service.dart';
import 'ui/screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService.instance.initialize();
  runApp(const WarcraftDefenderApp());
}

class WarcraftDefenderApp extends StatelessWidget {
  const WarcraftDefenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fort Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}
