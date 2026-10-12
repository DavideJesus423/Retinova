import 'case_database.dart';
import 'decision.dart';
import 'risk.dart';
import 'screening_record.dart';

export 'screening_record.dart';

/// Qual histórico mostrar: tudo, ou só um tipo de resultado.
enum HistoryFilter { all, ok, acompanhar, urgent, uncertain }

/// Contadores e histórico das triagens, guardados no banco.
/// Mesma ideia da fila: leitura pela memória, gravação também no disco.
class ScreeningStats {
  ScreeningStats(this._db);

  final CaseDatabase _db;
  final List<ScreeningRecord> _records = [];

  int get total => _records.length;
  int get uncertain => _records.where((r) => r.uncertain).length;
  int get urgent =>
      _records.where((r) => r.risk == Risk.encaminharUrgente).length;

  bool _matches(HistoryFilter f, ScreeningRecord r) => switch (f) {
        HistoryFilter.all => true,
        HistoryFilter.ok => r.risk == Risk.ok,
        HistoryFilter.acompanhar => r.risk == Risk.acompanhar,
        HistoryFilter.urgent => r.risk == Risk.encaminharUrgente,
        HistoryFilter.uncertain => r.uncertain,
      };

  /// Quantas triagens existem para esse filtro (usado nos cards da Home).
  int count(HistoryFilter f) => _records.where((r) => _matches(f, r)).length;

  /// Lista completa desse filtro, da mais recente para a mais antiga.
  List<ScreeningRecord> history(HistoryFilter f) =>
      _records.where((r) => _matches(f, r)).toList().reversed.toList();

  /// Últimas 5 triagens, da mais recente para a mais antiga.
  List<ScreeningRecord> get recent =>
      List.unmodifiable(_records.reversed.take(5));

  /// Chamado uma vez ao abrir o app.
  Future<void> load() async {
    _records
      ..clear()
      ..addAll(await _db.screenings());
  }

  Future<void> record(Decision d) async {
    final r = ScreeningRecord(risk: d.risk, time: DateTime.now());
    _records.add(r);
    try {
      await _db.insertScreening(r);
    } catch (_) {
      // Falha ao gravar o histórico não pode travar a triagem.
    }
  }
}
