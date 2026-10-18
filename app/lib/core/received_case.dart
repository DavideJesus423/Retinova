import 'pending_case.dart';
import 'risk.dart';

/// Um caso que já foi enviado e agora aparece no painel do especialista.
/// Continua sem nome nem dado do paciente (LGPD): só id e probabilidades.
class ReceivedCase {
  ReceivedCase({
    required this.id,
    required this.probs,
    required this.createdAt,
    required this.sentAt,
    this.decision,
  });

  final String id;
  final List<double> probs;
  final DateTime createdAt;
  final DateTime sentAt;

  /// O que o oftalmologista decidiu. null = ainda aguardando avaliação.
  final Risk? decision;

  bool get reviewed => decision != null;

  factory ReceivedCase.fromPending(PendingCase c, DateTime sentAt) =>
      ReceivedCase(
        id: c.id,
        probs: c.probs,
        createdAt: c.createdAt,
        sentAt: sentAt,
      );

  ReceivedCase withDecision(Risk r) => ReceivedCase(
        id: id,
        probs: probs,
        createdAt: createdAt,
        sentAt: sentAt,
        decision: r,
      );

  /// Linha do banco -> objeto.
  factory ReceivedCase.fromMap(Map<String, Object?> map) {
    final created = DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int);
    final sent = map['sent_at'] as int?; // casos antigos podem não ter
    final d = map['decision'] as int?;
    return ReceivedCase(
      id: map['id']! as String,
      probs: (map['probs']! as String).split(',').map(double.parse).toList(),
      createdAt: created,
      sentAt: sent == null ? created : DateTime.fromMillisecondsSinceEpoch(sent),
      decision: d == null ? null : Risk.values[d],
    );
  }
}
