import 'package:flutter/material.dart';

import 'core/case_database.dart';
import 'core/classifier.dart';
import 'core/tflite_classifier.dart';
import 'core/stats.dart';
import 'core/sync_queue.dart';
import 'core/sync_service.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

// main agora é async: antes de mostrar o app, abrimos o banco e carregamos
// os dados salvos (casos pendentes e histórico).
Future<void> main() async {
  // Necessário para usar plugins (como o sqflite) antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final db = await CaseDatabase.open();
  final queue = SyncQueue(db);
  final stats = ScreeningStats(db);
  await queue.load();
  await stats.load();

  // Troque FakeCaseSender pelo envio real quando houver servidor.
  final sync = SyncService(queue: queue, sender: FakeCaseSender());

  runApp(RetinovaApp(queue: queue, stats: stats, sync: sync));
}

class RetinovaApp extends StatefulWidget {
  const RetinovaApp({
    super.key,
    required this.queue,
    required this.stats,
    required this.sync,
  });

  final SyncQueue queue;
  final ScreeningStats stats;
  final SyncService sync;

  @override
  State<RetinovaApp> createState() => _RetinovaAppState();
}

class _RetinovaAppState extends State<RetinovaApp> {
  // Modelo real (TFLite). Para voltar ao classificador de teste (resultados
  // fixos, sem modelo), troque por: StubClassifier()
  final RetinaClassifier _classifier = TfliteClassifier();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retinova',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: SplashScreen(
        next: (_) => HomeScreen(
          classifier: _classifier,
          queue: widget.queue,
          stats: widget.stats,
          sync: widget.sync,
        ),
      ),
    );
  }
}
