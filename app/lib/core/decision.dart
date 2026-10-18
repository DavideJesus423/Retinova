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

/// Conformal prediction com um limiar (qhat) POR CLASSE:
/// a classe k entra no conjunto se p_k >= 1 - qhat_k.
/// Exatamente uma classe no conjunto -> decide; senão -> "não sei".
/// Deve se comportar igual a ml/src/retinova/conformal.py.
Decision decide(List<double> probs, List<double> qhats) {
  assert(probs.length == Risk.values.length);
  assert(qhats.length == Risk.values.length);
  final inSet = <int>[
    for (var k = 0; k < probs.length; k++)
      if (probs[k] >= 1.0 - qhats[k]) k,
  ];
  if (inSet.length == 1) {
    return Decision.certain(Risk.values[inSet.first], probs);
  }
  return Decision.uncertain(probs);
}
