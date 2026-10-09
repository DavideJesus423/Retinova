import 'package:flutter/material.dart';

import '../core/decision.dart';
import '../core/sync_queue.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.decision, required this.queue});

  final Decision decision;
  final SyncQueue queue;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  PendingCase? _queued;

  @override
  void initState() {
    super.initState();
    // Caso incerto vai para a fila local; o envio é feito quando houver conexão ou por SMS.
    if (widget.decision.uncertain) {
      _queued = widget.queue.enqueue(widget.decision);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.decision;
    final title = d.uncertain ? 'Não sei' : d.risk!.label;
    final body = d.uncertain
        ? 'A IA não tem certeza. O caso foi para a fila e será enviado ao oftalmologista parceiro.'
        : d.risk!.guidance;
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 16),
            const Text('Apoio à triagem. Não substitui avaliação médica.'),
            const Spacer(),
            if (_queued != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.sms),
                label: const Text('Enviar por SMS'),
                // TODO: número do oftalmologista parceiro vem de uma tela de ajustes.
                onPressed: () => widget.queue.sendBySms(_queued!, '+5500000000000'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Concluir'),
            ),
          ],
        ),
      ),
    );
  }
}
