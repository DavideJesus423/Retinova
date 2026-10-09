import 'package:flutter_test/flutter_test.dart';
import 'package:retinova/core/decision.dart';
import 'package:retinova/core/risk.dart';
import 'package:retinova/core/sync_queue.dart';

// Mesmos casos de ml/tests/test_conformal.py.
void main() {
  test('decide quando só uma classe passa do limiar', () {
    final d = decide([0.98, 0.01, 0.01], 0.5);
    expect(d.uncertain, isFalse);
    expect(d.risk, Risk.ok);
  });

  test('não sei quando nenhuma classe passa', () {
    expect(decide([0.45, 0.45, 0.10], 0.5).uncertain, isTrue);
  });

  test('não sei quando duas classes passam', () {
    expect(decide([0.55, 0.40, 0.05], 0.65).uncertain, isTrue);
  });

  test('mensagem de SMS sem dado identificável', () {
    final c = PendingCase(id: 'abc', probs: [0.45, 0.45, 0.10]);
    expect(c.toSmsBody(), 'RETINOVA|abc|ok|0.45,0.45,0.10');
  });
}
