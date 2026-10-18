import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/risk.dart';
import '../core/sync_queue.dart';
import '../theme.dart';

/// Painel simples do oftalmologista parceiro: lista dos casos recebidos.
/// (No protótipo, "recebidos" = casos que o app já enviou. Com servidor, esta
/// lista viria de lá.)
class SpecialistScreen extends StatefulWidget {
  const SpecialistScreen({super.key, required this.queue});

  final SyncQueue queue;

  @override
  State<SpecialistScreen> createState() => _SpecialistScreenState();
}

class _SpecialistScreenState extends State<SpecialistScreen> {
  Future<void> _open(ReceivedCase c) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _CaseDetailScreen(queue: widget.queue, caseId: c.id),
      ),
    );
    if (mounted) setState(() {}); // atualiza selos depois de decidir
  }

  @override
  Widget build(BuildContext context) {
    final cases = widget.queue.received;
    final waiting = widget.queue.awaitingReviewCount;
    return Scaffold(
      appBar: AppBar(title: const Text('Casos recebidos')),
      body: cases.isEmpty
          ? const _Empty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: cases.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      waiting == 0
                          ? 'Todos os casos foram avaliados'
                          : waiting == 1
                              ? '1 caso aguardando avaliação'
                              : '$waiting casos aguardando avaliação',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                final c = cases[index - 1];
                return _CaseCard(c: c, onTap: () => _open(c));
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Nenhum caso recebido ainda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Os casos incertos enviados pelos agentes aparecem aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.c, required this.onTap});

  final ReceivedCase c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Caso ${c.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  _StatusBadge(decision: c.decision),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Enviado ${formatDateTime(c.sentAt)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ProbBars(probs: c.probs, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.decision});

  final Risk? decision;

  @override
  Widget build(BuildContext context) {
    final d = decision;
    final Color bg = d?.tint ?? AppColors.offlineTint;
    final Color fg = d?.color ?? AppColors.offlineText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        d == null ? 'Aguardando' : d.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// As 3 probabilidades em barras coloridas (ok, acompanhar, urgente).
class ProbBars extends StatelessWidget {
  const ProbBars({super.key, required this.probs, this.compact = false});

  final List<double> probs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final r in Risk.values)
          Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 3 : 6),
            child: Row(
              children: [
                SizedBox(
                  width: compact ? 112 : 132,
                  child: Text(
                    r.label,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: probs[r.index].clamp(0.0, 1.0),
                      minHeight: compact ? 8 : 12,
                      color: r.color,
                      backgroundColor: r.tint,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(probs[r.index] * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Detalhe do caso + botões de decisão do especialista.
class _CaseDetailScreen extends StatefulWidget {
  const _CaseDetailScreen({required this.queue, required this.caseId});

  final SyncQueue queue;
  final String caseId;

  @override
  State<_CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<_CaseDetailScreen> {
  bool _saving = false;

  ReceivedCase get _case =>
      widget.queue.received.firstWhere((c) => c.id == widget.caseId);

  Future<void> _decide(Risk r) async {
    setState(() => _saving = true);
    await widget.queue.setDecision(widget.caseId, r);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Decisão registrada: ${r.label}.')));
  }

  @override
  Widget build(BuildContext context) {
    final c = _case;
    return Scaffold(
      appBar: AppBar(title: Text('Caso ${c.id}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Enviado ${formatDateTime(c.sentAt)}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                _StatusBadge(decision: c.decision),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'O que a IA calculou',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A IA não teve certeza. Estas são as probabilidades.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ProbBars(probs: c.probs),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sua avaliação',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            for (final r in Risk.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: Icon(r.icon, color: r.color),
                    label: Text(r.label),
                    style: c.decision == r
                        ? OutlinedButton.styleFrom(
                            backgroundColor: r.tint,
                            side: BorderSide(color: r.color, width: 2),
                          )
                        : null,
                    onPressed: _saving ? null : () => _decide(r),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              'Apoio à triagem, não diagnóstico. A decisão final é do profissional.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
