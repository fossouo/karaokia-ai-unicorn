class WordTimestamp {
  final String word;
  final double start;
  final double end;

  WordTimestamp({
    required this.word,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'start': start,
    'end': end,
  };

  factory WordTimestamp.fromJson(Map<String, dynamic> json) => WordTimestamp(
    word: json['word'],
    start: (json['start'] as num).toDouble(),
    end: (json['end'] as num).toDouble(),
  );
}

abstract class TranscriptionService {
  Future<List<WordTimestamp>> transcribe(String filePath);
}
