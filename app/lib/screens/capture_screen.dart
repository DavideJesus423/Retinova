import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/classifier.dart';
import '../core/decision.dart';
import '../core/stats.dart';
import '../core/sync_queue.dart';
import '../theme.dart';
import 'result_screen.dart';
import 'uncertain_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.classifier,
    required this.queue,
    required this.stats,
  });

  final RetinaClassifier classifier;
  final SyncQueue queue;
  final ScreeningStats stats;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _error;

  Future<void> _capture(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final shot = await _picker.pickImage(source: source);
      if (shot == null) return; // usuário cancelou
      final Decision d = await widget.classifier.classify(File(shot.path));
      if (!mounted) return;
      await widget.stats.record(d); // grava no histórico (banco)
      if (!mounted) return;
      // Certeza -> tela de resultado; dúvida -> tela de caso incerto.
      final Widget next = d.uncertain
          ? UncertainScreen(decision: d, queue: widget.queue)
          : ResultScreen(decision: d);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => next),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Não foi possível processar a imagem: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar retina')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.text,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_red_eye_outlined,
                                  size: 72, color: Colors.white54),
                              SizedBox(height: 12),
                              Text(
                                'Tire uma foto ou escolha uma da galeria',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _Tip('Encaixe a lente adaptadora no celular'),
                      const _Tip('Alinhe com o olho do paciente'),
                      const _Tip('Evite reflexos e mantenha o foco'),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_busy ? 'Processando...' : 'Tirar foto'),
                  onPressed:
                      _busy ? null : () => _capture(ImageSource.camera),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher da galeria'),
                  onPressed:
                      _busy ? null : () => _capture(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}
