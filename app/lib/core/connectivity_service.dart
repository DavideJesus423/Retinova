import 'package:connectivity_plus/connectivity_plus.dart';

/// Diz se o celular está conectado a alguma rede (wifi ou dados móveis).
///
/// Limite: isso mostra que HÁ rede, não que a internet funciona de verdade
/// (um wifi sem acesso conta como "online"). Para o protótipo basta; na versão
/// real, confirmaríamos com uma requisição de teste ao servidor.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // O pacote devolve uma LISTA de conexões ativas (wifi, dados, ...).
  // Se só tiver "none", não há rede.
  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// Estado agora (usado ao abrir a tela).
  Future<bool> checkNow() async =>
      _isOnline(await _connectivity.checkConnectivity());

  /// Avisa toda vez que a rede aparece ou some (ex.: modo avião).
  Stream<bool> get onChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();
}
