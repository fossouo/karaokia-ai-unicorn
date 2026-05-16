import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transcription_service.dart';

class KaraokeState {
  final String? audioPath;
  final List<WordTimestamp> timestamps;
  final bool isProcessing;
  final double currentPosition;
  final List<int> hiddenIndices;
  final List<int> revealedIndices;

  KaraokeState({
    this.audioPath,
    this.timestamps = const [],
    this.isProcessing = false,
    this.currentPosition = 0.0,
    this.hiddenIndices = const [],
    this.revealedIndices = const [],
  });

  KaraokeState copyWith({
    String? audioPath,
    List<WordTimestamp>? timestamps,
    bool? isProcessing,
    double? currentPosition,
    List<int>? hiddenIndices,
    List<int>? revealedIndices,
  }) {
    return KaraokeState(
      audioPath: audioPath ?? this.audioPath,
      timestamps: timestamps ?? this.timestamps,
      isProcessing: isProcessing ?? this.isProcessing,
      currentPosition: currentPosition ?? this.currentPosition,
      hiddenIndices: hiddenIndices ?? this.hiddenIndices,
      revealedIndices: revealedIndices ?? this.revealedIndices,
    );
  }
}

class KaraokeNotifier extends Notifier<KaraokeState> {
  @override
  KaraokeState build() {
    return KaraokeState();
  }

  void setAudioPath(String path) {
    state = state.copyWith(
      audioPath: path, 
      timestamps: [], 
      isProcessing: true, 
      hiddenIndices: [], 
      revealedIndices: []
    );
  }

  void setTimestamps(List<WordTimestamp> timestamps) {
    state = state.copyWith(timestamps: timestamps, isProcessing: false);
  }

  void setHiddenIndices(List<int> indices) {
    state = state.copyWith(hiddenIndices: indices);
  }

  void revealWord(int index) {
    state = state.copyWith(revealedIndices: [...state.revealedIndices, index]);
  }

  void updatePosition(double position) {
    state = state.copyWith(currentPosition: position);
  }
}

final karaokeProvider = NotifierProvider<KaraokeNotifier, KaraokeState>(() {
  return KaraokeNotifier();
});
