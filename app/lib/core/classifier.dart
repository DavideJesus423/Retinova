import 'dart:io';

import 'decision.dart';

/// Contrato do classificador. A implementação real (TFLite) entra nos Dias 3-4.
abstract class RetinaClassifier {
  Future<Decision> classify(File image);
}

/// Classificador falso, só para o fluxo do app funcionar antes do modelo existir.
/// Alterna resultados para exercitar todas as telas. NÃO usar fora do desenvolvimento.
class StubClassifier implements RetinaClassifier {
  StubClassifier({this.qhats = const [0.5, 0.5, 0.5]});

  final List<double> qhats;
  int _calls = 0;

  static const _samples = <List<double>>[
    [0.96, 0.03, 0.01], // ok
    [0.10, 0.85, 0.05], // acompanhar
    [0.02, 0.08, 0.90], // encaminhar urgente
    [0.45, 0.45, 0.10], // não sei
  ];

  @override
  Future<Decision> classify(File image) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final probs = _samples[_calls++ % _samples.length];
    return decide(probs, qhats);
  }
}
