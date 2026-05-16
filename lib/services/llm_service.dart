import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'model_manager.dart';
import 'transcription_service.dart';

class LlmService {
  LlamaProcessor? _processor;

  Future<void> init() async {
    final modelManager = ModelManager();
    const modelName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';
    
    await modelManager.ensureModelFromAssets(modelName);
    String modelPath = await modelManager.getModelPath(modelName);
    
    // Check if model exists
    if (await File(modelPath).exists()) {
      _processor = LlamaProcessor(
        path: modelPath,
        contextSize: 2048,
      );
    }
  }

  Future<List<int>> identifyMissingWords(List<WordTimestamp> timestamps) async {
    if (_processor == null) await init();
    if (_processor == null) return [2]; // Fallback: hide the 3rd word

    String lyrics = timestamps.map((e) => e.word).join(" ");
    String prompt = """
Analyze these song lyrics for a child learning to read. 
Select 3 important words to hide for a 'missing word' game. 
Return only the indices of these words as a comma-separated list.
Lyrics: $lyrics
Indices: """;

    // Simple generation logic
    // In a real app, we'd parse the output. For MVP, we'll return a fixed set or logic.
    return [1, 3, 4]; 
  }
}
