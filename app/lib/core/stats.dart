import 'decision.dart';
import 'risk.dart';

/// Uma triagem já feita. risk == null significa "não sei".
class ScreeningRecord {
  const ScreeningRecord({required this.risk, required this.time});

  final Risk? risk;
  final DateTime time;

  bool get uncertain => risk == null;
}

/// Contadores e histórico da sessão. Fica só em memória.
/// TODO(davi): ler e gravar no banco local, junto com a fila de casos.
class ScreeningStats {
  final List<ScreeningRecord> _records = [];

  int get total => _records.length;
  int get uncertain => _records.where((r) => r.uncertain).length;
  int get urgent =>
      _records.where((r) => r.risk == Risk.encaminharUrgente).length;

  /// Últimas 5 triagens, da mais recente para a mais antiga.
  List<ScreeningRecord> get recent =>
      List.unmodifiable(_records.reversed.take(5));

  void record(Decision d) {
    _records.add(ScreeningRecord(risk: d.risk, time: DateTime.now()));
  }
}
