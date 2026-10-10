import 'package:flutter/material.dart';

import '../core/classifier.dart';
import '../core/sync_queue.dart';
import '../theme.dart';
import '../widgets/connection_chip.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.classifier, required this.queue});

  final RetinaClassifier classifier;
  final SyncQueue queue;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO(davi): ligar ao connectivity_plus (onConnectivityChanged).
  // Enquanto isso, toque longo no selo alterna o estado para testar o visual.
  bool _online = false;

  Future<void> _newScreening() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CaptureScreen(
          classifier: widget.classifier,
          queue: widget.queue,
        ),
      ),
    );
    if (mounted) setState(() {}); // atualiza o contador de pendentes
  }

  void _syncNow() {
    // TODO(davi): enviar os casos pendentes e marcar como enviados.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronização ainda não implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.queue.items.length;
    return Scaffold(
      body: Column(
        children: [
          _Header(
            online: _online,
            onChipLongPress: () => setState(() => _online = !_online),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Nova triagem'),
                      onPressed: _newScreening,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PendingCard(count: pending, onSync: _syncNow),
                  const SizedBox(height: 28),
                  const Text(
                    'Apoio à triagem. Não faz diagnóstico.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.online, required this.onChipLongPress});

  final bool online;
  final VoidCallback onChipLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 24,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olá!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Retinova',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ConnectionChip(online: online, onLongPress: onChipLongPress),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.count, required this.onSync});

  final int count;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aguardando o especialista',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 1 ? '1 caso' : '$count casos',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: count == 0 ? null : onSync,
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
