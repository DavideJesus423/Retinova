import 'risk.dart';

/// Uma triagem já feita. risk == null significa "não sei".
class ScreeningRecord {
  const ScreeningRecord({required this.risk, required this.time});

  final Risk? risk;
  final DateTime time;

  bool get uncertain => risk == null;

  /// O risco é guardado como número (a posição no enum Risk: 0, 1 ou 2).
  /// Vazio (null) quer dizer "não sei". Por isso a ORDEM do enum em risk.dart
  /// não pode mudar depois que houver dados salvos.
  Map<String, Object?> toMap() => {
        'risk': risk?.index,
        'created_at': time.millisecondsSinceEpoch,
      };

  factory ScreeningRecord.fromMap(Map<String, Object?> map) {
    final r = map['risk'] as int?;
    return ScreeningRecord(
      risk: r == null ? null : Risk.values[r],
      time: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    );
  }
}
