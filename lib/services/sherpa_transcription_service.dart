import 'dart:io';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'transcription_service.dart';
import 'model_manager.dart';

class SherpaTranscriptionService implements TranscriptionService {
  sherpa.OfflineRecognizer? _recognizer;

  Future<void> init() async {
    final modelManager = ModelManager();
    
    // Ensure models are copied from assets to local storage if needed
    await modelManager.ensureModelFromAssets('whisper-tiny-encoder.onnx');
    await modelManager.ensureModelFromAssets('whisper-tiny-decoder.onnx');
    await modelManager.ensureModelFromAssets('whisper-tiny-tokens.txt');

    // Paths for Whisper Tiny model
    String encoder = await modelManager.getModelPath('whisper-tiny-encoder.onnx');
    String decoder = await modelManager.getModelPath('whisper-tiny-decoder.onnx');
    String tokens = await modelManager.getModelPath('whisper-tiny-tokens.txt');

    // For MVP, we assume models are already there or handled by ModelManager
    if (await File(encoder).exists()) {
      var config = sherpa.OfflineRecognizerConfig(
        model: sherpa.OfflineModelConfig(
          whisper: sherpa.OfflineWhisperModelConfig(
            encoder: encoder,
            decoder: decoder,
            tokens: tokens,
          ),
        ),
      );
      _recognizer = sherpa.OfflineRecognizer(config);
    }
  }

  @override
  Future<List<WordTimestamp>> transcribe(String filePath) async {
    if (_recognizer == null) await init();
    if (_recognizer == null) throw Exception("Recognizer not initialized");

    // Load audio and transcribe
    // sherpa_onnx requires 16kHz mono PCM
    // We would normally use a converter here, but for MVP we assume compatible audio
    var waveData = await File(filePath).readAsBytes();
    // This is a simplified call; real sherpa_onnx needs wave parsing
    var stream = _recognizer!.createStream();
    stream.acceptWaveform(samples: waveData.buffer.asFloat32List(), sampleRate: 16000);
    _recognizer!.decode(stream);
    
    var result = _recognizer!.getResult(stream);
    
    // Convert sherpa result to WordTimestamp
    // Note: real implementation would parse the tokens and timestamps from result
    return result.tokens.asMap().entries.map((e) {
      return WordTimestamp(
        word: e.value,
        start: 0.0, // Should extract from result.timestamps
        end: 0.0,
      );
    }).toList();
  }
}
