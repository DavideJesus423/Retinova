import 'package:url_launcher/url_launcher.dart';

import 'decision.dart';
import 'risk.dart';

/// Caso incerto aguardando envio ao oftalmologista parceiro.
/// Sem dados identificáveis do paciente (LGPD): só um id local e as probabilidades.
class PendingCase {
  PendingCase({required this.id, required this.probs, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String id;
  final List<double> probs;
  final DateTime createdAt;

  /// Formato: RETINOVA|id|risco-mais-provável|p0,p1,p2
  String toSmsBody() {
    var top = 0;
    for (var k = 1; k < probs.length; k++) {
      if (probs[k] > probs[top]) top = k;
    }
    final p = probs.map((v) => v.toStringAsFixed(2)).join(',');
    return 'RETINOVA|$id|${Risk.values[top].name}|$p';
  }
}

/// Fila local. Implementação em memória; trocar por sqflite para persistir (docs/ARQUITETURA.md).
class SyncQueue {
  final List<PendingCase> _items = [];

  List<PendingCase> get items => List.unmodifiable(_items);

  PendingCase enqueue(Decision decision) {
    final c = PendingCase(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(36),
      probs: decision.probs,
    );
    _items.add(c);
    return c;
  }

  void remove(String id) => _items.removeWhere((c) => c.id == id);

  /// Abre o app de SMS do aparelho com a mensagem pronta.
  /// [phone] é o número do oftalmologista parceiro (configurar em tela de ajustes).
  Future<bool> sendBySms(PendingCase c, String phone) {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': c.toSmsBody()},
    );
    return launchUrl(uri);
  }
}
