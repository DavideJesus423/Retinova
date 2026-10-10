import 'package:flutter/material.dart';

import '../core/decision.dart';
import '../theme.dart';

/// Resultado com certeza: ok / acompanhar / encaminhar urgente.
/// (O caso "não sei" vai para a UncertainScreen.)
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.decision});

  final Decision decision;

  @override
  Widget build(BuildContext context) {
    final risk = decision.risk!;
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
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
                  decoration:
                      BoxDecoration(color: risk.tint, shape: BoxShape.circle),
                  child: Icon(risk.icon, size: 64, color: risk.color),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                risk.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: risk.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                risk.guidance,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.text),
              ),
              const Spacer(),
              const Text(
                'Apoio à triagem. Não substitui avaliação médica.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Concluir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
