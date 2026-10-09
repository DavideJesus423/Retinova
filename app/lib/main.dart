import 'package:flutter/material.dart';

import 'core/classifier.dart';
import 'core/sync_queue.dart';
import 'screens/home_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retinova',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B6E4F),
        useMaterial3: true,
      ),
      home: HomeScreen(classifier: _classifier, queue: _queue),
    );
  }
}
