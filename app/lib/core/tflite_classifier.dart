import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'classifier.dart';
import 'decision.dart';

/// Classificador real: roda o modelo TFLite no próprio aparelho (sem internet).
///
/// O que sabemos do modelo (lido do arquivo .tflite):
///   entrada: [1, 224, 224, 3]  float32  (NHWC, RGB)
///   saída:   [1, 3]            float32  ("logits": ainda NÃO são probabilidades)
///
/// O que PRECISA ser confirmado com quem treinou (não está no arquivo):
///   1) normalização dos pixels  -> abaixo assumimos a do ImageNet
///   2) ordem das classes        -> [ok, acompanhar, urgente] (índices 0, 1, 2)
///
/// Calibração (informada por quem treinou o modelo):
///   - temperatura T: os logits são divididos por T antes do softmax
///   - qhat POR CLASSE (conformal): classe k fica no conjunto se p_k >= 1 - qhat_k
class TfliteClassifier implements RetinaClassifier {
  TfliteClassifier({this.qhats = defaultQhats});

  // ---- AJUSTAR COM O COLEGA DO MODELO -------------------------------------
  /// Temperatura da calibração (suaviza as probabilidades do modelo).
  static const double temperature = 1.8621324744734113;

  /// qhat por classe, na ordem [ok, acompanhar, urgente].
  static const List<double> defaultQhats = [
    0.0812157714667383, // ok
    0.6256589928986585, // acompanhar
    0.7467765468872558, // encaminhar urgente
  ];

  static const int inputSize = 224;
  static const List<double> mean = [0.485, 0.456, 0.406]; // ImageNet (R,G,B)
  static const List<double> std = [0.229, 0.224, 0.225];
  static const String modelAsset = 'assets/retinova_float32.tflite';
  // --------------------------------------------------------------------------

  final List<double> qhats;
  Interpreter? _interpreter;

  /// Carrega o modelo na primeira vez que for usado (e só nessa).
  Future<Interpreter> _load() async =>
      _interpreter ??= await Interpreter.fromAsset(modelAsset);

  @override
  Future<Decision> classify(File image) async {
    final total = Stopwatch()..start();
    final interpreter = await _load();

    // Decodificar e redimensionar uma foto grande é pesado: faz em outra
    // thread (compute) para a tela não travar.
    final Float32List pixels = await compute(_preprocess, image.path);

    final input = pixels.reshape([1, inputSize, inputSize, 3]);
    final output = [List<double>.filled(3, 0.0)];
    interpreter.run(input, output);

    final probs = softmax(output[0], temperature: temperature);
    // Para o teste do Dia 6: anote este tempo (aparece no terminal do flutter run).
    debugPrint('RETINOVA tempo total da análise: ${total.elapsedMilliseconds} ms');
    return decide(probs, qhats);
  }
}

/// Foto -> lista de números que o modelo entende.
/// Roda em outra thread, por isso é uma função "solta" (top-level).
Float32List _preprocess(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) {
    throw const FormatException('Não consegui abrir essa imagem.');
  }
  // Fotos de celular vêm "deitadas" com um aviso de rotação (EXIF): corrige.
  final oriented = img.bakeOrientation(decoded);
  final resized = img.copyResize(
    oriented,
    width: TfliteClassifier.inputSize,
    height: TfliteClassifier.inputSize,
    interpolation: img.Interpolation.average,
  );

  final out = Float32List(
    TfliteClassifier.inputSize * TfliteClassifier.inputSize * 3,
  );
  var i = 0;
  for (var y = 0; y < TfliteClassifier.inputSize; y++) {
    for (var x = 0; x < TfliteClassifier.inputSize; x++) {
      final p = resized.getPixel(x, y);
      final rgb = [p.r / 255.0, p.g / 255.0, p.b / 255.0];
      for (var c = 0; c < 3; c++) {
        out[i++] = (rgb[c] - TfliteClassifier.mean[c]) / TfliteClassifier.std[c];
      }
    }
  }
  return out;
}

/// Transforma as 3 saídas brutas (logits) em probabilidades que somam 1.
/// [temperature] > 1 deixa as probabilidades menos "confiantes" (calibração).
List<double> softmax(List<double> logits, {double temperature = 1.0}) {
  final scaled = [for (final v in logits) v / temperature];
  final m = scaled.reduce(math.max); // subtrair o maior evita estouro numérico
  final exps = [for (final v in scaled) math.exp(v - m)];
  final sum = exps.reduce((a, b) => a + b);
  return [for (final e in exps) e / sum];
}
