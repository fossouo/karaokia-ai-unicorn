import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'transcription_service.dart';

class RemoteAiService implements TranscriptionService {
  final String baseUrl = 'http://100.68.204.117:4000';
  final String apiKey = 'sk-unused';

  @override
  Future<List<WordTimestamp>> transcribe(String filePath) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio/transcriptions'));
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['timestamp_granularities[]'] = 'word';
    request.fields['response_format'] = 'verbose_json';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      if (data['words'] != null) {
        return (data['words'] as List).map((w) => WordTimestamp(
          word: w['word'],
          start: (w['start'] as num).toDouble(),
          end: (w['end'] as num).toDouble(),
        )).toList();
      }
      return [];
    } else {
      throw Exception('Failed to transcribe: ${response.statusCode}');
    }
  }

  Future<List<int>> identifyMissingWords(List<WordTimestamp> timestamps) async {
    String lyrics = timestamps.map((e) => e.word).join(" ");
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'coder',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an educational assistant. Analyze lyrics and pick 3 words to hide for a learning game. Return ONLY a comma-separated list of word indices (starting at 0).'
          },
          {'role': 'user', 'content': 'Lyrics: $lyrics'}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String content = data['choices'][0]['message']['content'];
      return content.split(',').map((s) => int.tryParse(s.trim()) ?? -1).where((i) => i >= 0).toList();
    } else {
      return [2, 5, 8]; // Fixed indices fallback
    }
  }
}
