import 'package:flutter/material.dart';

import '../core/classifier.dart';
import '../core/sync_queue.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.classifier, required this.queue});

  final RetinaClassifier classifier;
  final SyncQueue queue;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final pending = widget.queue.items.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Retinova')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Triagem de retinopatia diabética. Ferramenta de apoio, não faz diagnóstico.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Nova triagem'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CaptureScreen(
                      classifier: widget.classifier,
                      queue: widget.queue,
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sync),
              title: Text('Casos aguardando o especialista: $pending'),
            ),
          ],
        ),
      ),
    );
  }
}
