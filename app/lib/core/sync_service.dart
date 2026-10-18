import 'sync_queue.dart';

/// Quem envia um caso ao oftalmologista. Devolve true se deu certo.
/// Hoje existe só a versão falsa abaixo; quando houver servidor (ou outro
/// canal), cria-se outra classe com este mesmo método e troca no main.dart.
abstract class CaseSender {
  Future<bool> send(PendingCase c);
}

/// Envio de mentira: espera 1 segundo e diz que deu certo.
/// Serve para testar o fluxo completo antes de existir um servidor.
class FakeCaseSender implements CaseSender {
  @override
  Future<bool> send(PendingCase c) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }
}

/// Percorre a fila e envia os casos pendentes, um por vez.
class SyncService {
  SyncService({required this.queue, required this.sender});

  final SyncQueue queue;
  final CaseSender sender;
  bool _running = false;

  bool get running => _running;

  /// Envia todos os pendentes. Devolve quantos foram enviados.
  /// Se um envio falhar, para na hora (provavelmente a rede caiu) e deixa os
  /// restantes como 'pending' para tentar de novo depois.
  Future<int> syncAll() async {
    if (_running) return 0; // evita dois envios ao mesmo tempo
    _running = true;
    var sent = 0;
    try {
      for (final c in List<PendingCase>.of(queue.items)) {
        try {
          final ok = await sender.send(c);
          if (!ok) break;
          await queue.markSent(c.id); // sai da fila e vira 'sent' no banco
          sent++;
        } catch (_) {
          break;
        }
      }
    } finally {
      _running = false;
    }
    return sent;
  }
}
