/// Um caso incerto ("não sei") esperando para ir ao oftalmologista.
/// Não guarda nome nem dado do paciente (LGPD): só um id e as probabilidades.
class PendingCase {
  PendingCase({required this.id, required this.probs, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String id;
  final List<double> probs;
  final DateTime createdAt;

  /// Objeto -> linha do banco. As probabilidades viram um texto "0.45,0.45,0.1",
  /// porque uma coluna do SQLite guarda um valor só, não uma lista.
  Map<String, Object?> toMap() => {
        'id': id,
        'probs': probs.join(','),
        'created_at': createdAt.millisecondsSinceEpoch, // data como número
        'status': 'pending',
      };

  /// Linha do banco -> objeto (o caminho de volta).
  factory PendingCase.fromMap(Map<String, Object?> map) => PendingCase(
        id: map['id']! as String,
        probs: (map['probs']! as String).split(',').map(double.parse).toList(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      );

  /// Formato do SMS: RETINOVA|id|incerto|p0,p1,p2
  /// O campo de risco é sempre "incerto": o app NÃO decidiu, quem decide é o
  /// oftalmologista. As probabilidades (ok, acompanhar, urgente) vão como
  /// apoio para ele.
  String toSmsBody() {
    final p = probs.map((v) => v.toStringAsFixed(2)).join(',');
    return 'RETINOVA|$id|incerto|$p';
  }
}
