# app

App Flutter do Retinova.

```bash
flutter create . --platforms=android --project-name retinova   # só na 1ª vez: gera android/
flutter pub get
flutter test
flutter run
```

Na permissão de câmera do Android, o `image_picker` já cuida do pedido em tempo de execução.
Para SMS, o app abre o aplicativo de mensagens do aparelho (`sms:`), sem pedir permissão de envio.

## Código

- `lib/core/risk.dart`: enum de risco.
- `lib/core/decision.dart`: regra conformal (igual à de `ml/`).
- `lib/core/classifier.dart`: interface do classificador + `StubClassifier` (substituir pelo TFLite).
- `lib/core/sync_queue.dart`: fila de casos incertos e mensagem de SMS.
- `lib/screens/`: início, captura e resultado.
