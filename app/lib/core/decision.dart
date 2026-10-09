import 'risk.dart';

/// Resultado de uma classificação: um risco, ou "não sei" (risk == null).
class Decision {
  const Decision.certain(this.risk, this.probs) : uncertain = false;
  const Decision.uncertain(this.probs)
      : risk = null,
        uncertain = true;

  final Risk? risk;
  final bool uncertain;
  final List<double> probs;
}

/// Conformal prediction: conjunto = {k : p_k >= 1 - qhat}.
/// Exatamente uma classe -> decide; caso contrário -> "não sei".
/// Deve se comportar igual a ml/src/retinova/conformal.py.
Decision decide(List<double> probs, double qhat) {
  assert(probs.length == Risk.values.length);
  final threshold = 1.0 - qhat;
  final inSet = <int>[
    for (var k = 0; k < probs.length; k++)
      if (probs[k] >= threshold) k,
  ];
  if (inSet.length == 1) {
    return Decision.certain(Risk.values[inSet.first], probs);
  }
  return Decision.uncertain(probs);
}
