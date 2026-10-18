import 'package:url_launcher/url_launcher.dart';

import 'case_database.dart';
import 'decision.dart';
import 'pending_case.dart';
import 'received_case.dart';
import 'risk.dart';

export 'pending_case.dart';
export 'received_case.dart';

/// Fila de casos incertos esperando o especialista.
///
/// Guarda os casos em DOIS lugares:
///  - memória (_items): leitura rápida; as telas leem daqui, sem esperar.
///  - banco (disco): para não perder nada ao fechar o app.
/// Ao abrir o app, load() copia o banco para a memória.
class SyncQueue {
  SyncQueue(this._db);

  final CaseDatabase _db;
  final List<PendingCase> _items = [];
  final List<ReceivedCase> _received = []; // painel do especialista

  List<PendingCase> get items => List.unmodifiable(_items);

  /// Casos enviados (painel do especialista), do mais novo para o mais antigo.
  List<ReceivedCase> get received => List.unmodifiable(_received);
  int get reviewedCount => _received.where((c) => c.reviewed).length;
  int get awaitingReviewCount => _received.length - reviewedCount;

  /// Chamado uma vez ao abrir o app: traz do banco os casos ainda pendentes.
  Future<void> load() async {
    _items
      ..clear()
      ..addAll(await _db.pendingCases());
    _received
      ..clear()
      ..addAll(await _db.receivedCases());
  }

  /// Cria o caso, mostra na memória na hora e grava no banco.
  Future<PendingCase> enqueue(Decision decision) async {
    final c = PendingCase(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(36),
      probs: decision.probs,
    );
    _items.add(c); // memória: aparece na tela imediatamente
    await _db.insertCase(c); // disco: sobrevive ao fechar o app
    return c;
  }

  /// Marca como enviado: sai da fila de pendentes (fica no banco como 'sent').
  Future<void> markSent(String id) async {
    await _db.markSent(id);
    final i = _items.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final c = _items.removeAt(i);
    _received.insert(0, ReceivedCase.fromPending(c, DateTime.now()));
  }

  /// O especialista registra a decisão sobre um caso recebido.
  Future<void> setDecision(String id, Risk decision) async {
    await _db.setDecision(id, decision);
    final i = _received.indexWhere((c) => c.id == id);
    if (i != -1) _received[i] = _received[i].withDecision(decision);
  }

  /// Abre o app de SMS do aparelho com a mensagem pronta.
  /// [phone] é o número do oftalmologista parceiro.
  Future<bool> sendBySms(PendingCase c, String phone) {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': c.toSmsBody()},
    );
    return launchUrl(uri);
  }
}
