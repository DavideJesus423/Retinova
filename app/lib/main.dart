import 'package:flutter/material.dart';

import 'core/classifier.dart';
import 'core/stats.dart';
import 'core/sync_queue.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() => runApp(const RetinovaApp());

class RetinovaApp extends StatefulWidget {
  const RetinovaApp({super.key});

  @override
  State<RetinovaApp> createState() => _RetinovaAppState();
}

class _RetinovaAppState extends State<RetinovaApp> {
  // Trocar StubClassifier pelo classificador TFLite quando o modelo estiver pronto.
  final RetinaClassifier _classifier = StubClassifier();
  final SyncQueue _queue = SyncQueue();
  final ScreeningStats _stats = ScreeningStats();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retinova',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: SplashScreen(
        next: (_) => HomeScreen(
          classifier: _classifier,
          queue: _queue,
          stats: _stats,
        ),
      ),
    );
  }
}
