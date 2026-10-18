import 'package:flutter_test/flutter_test.dart';
import 'package:retinova/core/decision.dart';
import 'package:retinova/core/tflite_classifier.dart';
import 'package:retinova/core/risk.dart';
import 'package:retinova/core/sync_queue.dart';

// Mesmos casos de ml/tests/test_conformal.py.
void main() {
  test('decide quando só uma classe passa do limiar', () {
    final d = decide([0.98, 0.01, 0.01], [0.5, 0.5, 0.5]);
    expect(d.uncertain, isFalse);
    expect(d.risk, Risk.ok);
  });

  test('não sei quando nenhuma classe passa', () {
    expect(decide([0.45, 0.45, 0.10], [0.5, 0.5, 0.5]).uncertain, isTrue);
  });

  test('não sei quando duas classes passam', () {
    expect(decide([0.55, 0.40, 0.05], [0.65, 0.65, 0.65]).uncertain, isTrue);
  });

  test('mensagem de SMS sem dado identificável', () {
    final c = PendingCase(id: 'abc', probs: [0.45, 0.45, 0.10]);
    expect(c.toSmsBody(), 'RETINOVA|abc|incerto|0.45,0.45,0.10');
  });

  test('softmax soma 1 e mantém a ordem dos logits', () {
    final p = softmax([0.97, -0.27, -0.22]);
    expect(p.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
    expect(p[0] > p[2] && p[2] > p[1], isTrue);
  });

  // Com os qhat reais por classe: limiares 0.919 (ok), 0.374 (acompanhar), 0.253 (urgente).
  group('qhat por classe (calibração real)', () {
    const q = TfliteClassifier.defaultQhats;

    test('ok só com muita confiança', () {
      expect(decide([0.95, 0.03, 0.02], q).risk, Risk.ok);
      // 0.85 < 0.919 e nenhuma outra passa -> conjunto vazio -> não sei
      expect(decide([0.85, 0.10, 0.05], q).uncertain, isTrue);
    });

    test('acompanhar passa com confiança moderada', () {
      expect(decide([0.50, 0.40, 0.10], q).risk, Risk.acompanhar);
    });

    test('duas classes no conjunto -> não sei', () {
      expect(decide([0.20, 0.40, 0.40], q).uncertain, isTrue);
    });

    test('temperatura deixa a saída menos extrema', () {
      final cru = softmax([4.0, 0.0, 0.0]);
      final calibrado = softmax([4.0, 0.0, 0.0],
          temperature: TfliteClassifier.temperature);
      expect(calibrado[0] < cru[0], isTrue);
      expect(calibrado.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
    });
  });
}
