import 'package:flutter/material.dart';

import '../core/classifier.dart';
import '../core/format.dart';
import '../core/stats.dart';
import '../core/sync_queue.dart';
import '../theme.dart';
import '../widgets/connection_chip.dart';
import 'capture_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.classifier,
    required this.queue,
    required this.stats,
  });

  final RetinaClassifier classifier;
  final SyncQueue queue;
  final ScreeningStats stats;

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
          stats: widget.stats,
        ),
      ),
    );
    if (mounted) setState(() {}); // atualiza contadores e histórico
  }

  void _openHistory(HistoryFilter filter) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(filter: filter, stats: widget.stats),
      ),
    );
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
    final stats = widget.stats;
    return Scaffold(
      body: Column(
        children: [
          _Header(
            online: _online,
            onChipLongPress: () => setState(() => _online = !_online),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: _FadeSlide(
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
                    const SizedBox(height: 8),
                    const Text(
                      'Funciona sem internet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Resumo'),
                    _TotalCard(
                      value: stats.count(HistoryFilter.all),
                      onTap: () => _openHistory(HistoryFilter.all),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline,
                            label: 'Ok',
                            value: stats.count(HistoryFilter.ok),
                            color: AppColors.ok,
                            tint: AppColors.okTint,
                            onTap: () => _openHistory(HistoryFilter.ok),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.schedule,
                            label: 'Acompanhar',
                            value: stats.count(HistoryFilter.acompanhar),
                            color: AppColors.warn,
                            tint: AppColors.warnTint,
                            onTap: () => _openHistory(HistoryFilter.acompanhar),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.warning_amber_rounded,
                            label: 'Urgentes',
                            value: stats.count(HistoryFilter.urgent),
                            color: AppColors.urgent,
                            tint: AppColors.urgentTint,
                            onTap: () => _openHistory(HistoryFilter.urgent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.help_outline,
                            label: 'Não sei',
                            value: stats.count(HistoryFilter.uncertain),
                            color: AppColors.textMuted,
                            tint: AppColors.border,
                            onTap: () => _openHistory(HistoryFilter.uncertain),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _PendingCard(count: pending, onSync: _syncNow),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      'Últimas triagens',
                      action: TextButton(
                        onPressed: () => _openHistory(HistoryFilter.all),
                        child: const Text('Ver tudo'),
                      ),
                    ),
                    _RecentList(records: stats.recent),
                    const SizedBox(height: 24),
                    const _SectionTitle('Como funciona'),
                    const _HowItWorks(),
                    const SizedBox(height: 24),
                    const Text(
                      'Apoio à triagem. Não faz diagnóstico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entrada suave do conteúdo: aparece com fade e sobe um pouco.
class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: child,
    );
  }
}

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Bom dia';
  if (h < 18) return 'Boa tarde';
  return 'Boa noite';
}

class _Header extends StatelessWidget {
  const _Header({required this.online, required this.onChipLongPress});

  final bool online;
  final VoidCallback onChipLongPress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF2B3CCB)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(right: -36, top: -28, child: _Bubble(size: 150)),
            const Positioned(left: -44, bottom: -56, child: _Bubble(size: 130)),
            const Positioned(right: 70, bottom: 18, child: _Bubble(size: 34)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 22,
                20,
                26,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove_red_eye,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()}, agente!',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Retinova',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ConnectionChip(online: online, onLongPress: onChipLongPress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x14FFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: action == null ? 10 : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    );

/// Card tocável: o InkWell dá o efeito de toque; o Ink desenha o fundo do card.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: _cardDecoration(),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                  child: Icon(icon, size: 19, color: color),
                ),
                const SizedBox(height: 10),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card largo "Triagens": abre o histórico de todos os resultados.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: _cardDecoration(),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Triagens',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Histórico de todos os resultados',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
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
      decoration: _cardDecoration(),
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
                  count == 1 ? '1 caso salvo no aparelho' : '$count casos salvos no aparelho',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
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

class _RecentList extends StatelessWidget {
  const _RecentList({required this.records});

  final List<ScreeningRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: _cardDecoration(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 20, color: AppColors.textMuted),
            SizedBox(width: 8),
            Text(
              'Nenhuma triagem ainda',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _RecentRow(record: records[i]),
          ],
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.record});

  final ScreeningRecord record;

  @override
  Widget build(BuildContext context) {
    final risk = record.risk;
    final color = risk?.color ?? AppColors.warn;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              risk?.label ?? 'Não sei (enviado à fila)',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            formatTime(record.time),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          _Step(
            number: 1,
            icon: Icons.camera_alt_outlined,
            title: 'Fotografe a retina',
            text: 'Com o celular e a lente adaptadora.',
          ),
          SizedBox(height: 14),
          _Step(
            number: 2,
            icon: Icons.memory,
            title: 'A IA analisa no aparelho',
            text: 'Sem precisar de internet.',
          ),
          SizedBox(height: 14),
          _Step(
            number: 3,
            icon: Icons.medical_services_outlined,
            title: 'Resultado ou especialista',
            text: 'Se houver dúvida, o caso vai para o oftalmologista.',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });

  final int number;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. $title',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
