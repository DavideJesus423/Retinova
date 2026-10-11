import 'package:flutter/material.dart';

import '../core/decision.dart';
import '../core/sync_queue.dart';
import '../theme.dart';

/// "Caso incerto": a IA não decidiu com segurança.
/// O caso é salvo na fila local e pode ser enviado ao especialista.
class UncertainScreen extends StatefulWidget {
  const UncertainScreen({super.key, required this.decision, required this.queue});

  final Decision decision;
  final SyncQueue queue;

  @override
  State<UncertainScreen> createState() => _UncertainScreenState();
}

class _UncertainScreenState extends State<UncertainScreen> {
  // TODO(davi): número do oftalmologista parceiro (tela de ajustes ou constante).
  static const _partnerPhone = '+5500000000000';

  // Fica vazio até o caso ser salvo no banco (leva uma fração de segundo).
  PendingCase? _queued;

  @override
  void initState() {
    super.initState();
    _saveCase();
  }

  /// Salva o caso na fila (memória + banco). Só depois disso o botão
  /// "Enviar para especialista" é liberado.
  Future<void> _saveCase() async {
    try {
      final c = await widget.queue.enqueue(widget.decision);
      if (!mounted) return;
      setState(() => _queued = c);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o caso no aparelho.'),
        ),
      );
    }
  }

  Future<void> _sendToSpecialist() async {
    final queued = _queued;
    if (queued == null) return;
    var opened = false;
    try {
      opened = await widget.queue.sendBySms(queued, _partnerPhone);
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o app de mensagens.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caso incerto')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.warnTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 64,
                    color: AppColors.warn,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Não tenho certeza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A IA não conseguiu decidir com segurança. '
                'Envie o caso para o oftalmologista parceiro avaliar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Caso salvo no aparelho, mesmo sem internet',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar para especialista'),
                  onPressed: _queued == null ? null : _sendToSpecialist,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Enviar depois'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
