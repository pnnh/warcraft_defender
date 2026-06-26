import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'game/game_state.dart';
import 'data/persistence_service.dart';
import 'ui/screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // setPreferredOrientations is a no-op on web and can throw on some configs.
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  await PersistenceService.instance.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: GameState.instance,
      child: const WarcraftDefenderApp(),
    ),
  );
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
