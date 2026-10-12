import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/stats.dart';
import '../theme.dart';

/// Histórico de triagens: de tudo, ou só de um tipo de resultado.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.filter, required this.stats});

  final HistoryFilter filter;
  final ScreeningStats stats;

  String get _title => switch (filter) {
        HistoryFilter.all => 'Todas as triagens',
        HistoryFilter.ok => 'Resultados Ok',
        HistoryFilter.acompanhar => 'Acompanhar',
        HistoryFilter.urgent => 'Encaminhar urgente',
        HistoryFilter.uncertain => 'Não sei',
      };

  @override
  Widget build(BuildContext context) {
    final records = stats.history(filter);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: records.isEmpty
          ? const _Empty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: records.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      records.length == 1
                          ? '1 triagem'
                          : '${records.length} triagens',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return _Row(record: records[index - 1]);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Nenhuma triagem aqui ainda',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.record});

  final ScreeningRecord record;

  @override
  Widget build(BuildContext context) {
    final risk = record.risk;
    final color = risk?.color ?? AppColors.warn;
    final tint = risk?.tint ?? AppColors.warnTint;
    final icon = risk?.icon ?? Icons.help_outline;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  risk?.label ?? 'Não sei',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDateTime(record.time),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
