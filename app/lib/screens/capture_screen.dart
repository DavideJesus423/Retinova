import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/classifier.dart';
import '../core/decision.dart';
import '../core/sync_queue.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.classifier, required this.queue});

  final RetinaClassifier classifier;
  final SyncQueue queue;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _error;

  Future<void> _capture() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final shot = await _picker.pickImage(source: ImageSource.camera);
      if (shot == null) return; // usuário cancelou
      final Decision d = await widget.classifier.classify(File(shot.path));
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(decision: d, queue: widget.queue),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Não foi possível processar a imagem: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar retina')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Encaixe a lente adaptadora, alinhe com o olho do paciente e fotografe. '
              'Evite reflexos e mantenha a imagem focada.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(_busy ? 'Processando...' : 'Abrir câmera'),
              onPressed: _busy ? null : _capture,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
