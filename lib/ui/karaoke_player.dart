import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/karaoke_provider.dart';

class KaraokePlayer extends ConsumerStatefulWidget {
  const KaraokePlayer({super.key});

  @override
  ConsumerState<KaraokePlayer> createState() => _KaraokePlayerState();
}

class _KaraokePlayerState extends ConsumerState<KaraokePlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioPath = ref.read(karaokeProvider).audioPath;
    if (audioPath != null) {
      if (audioPath.startsWith('assets/')) {
        await _audioPlayer.setSource(AssetSource(audioPath.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.setSource(DeviceFileSource(audioPath));
      }
      _audioPlayer.onPositionChanged.listen((position) {
        ref.read(karaokeProvider.notifier).updatePosition(position.inMilliseconds / 1000.0);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karaokeState = ref.watch(karaokeProvider);
    final currentPos = karaokeState.currentPosition;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: karaokeState.timestamps.asMap().entries.map((entry) {
                final index = entry.key;
                final ts = entry.value;
                final isActive = currentPos >= ts.start && currentPos <= ts.end;
                final isHidden = karaokeState.hiddenIndices.contains(index) && 
                                !karaokeState.revealedIndices.contains(index);

                return GestureDetector(
                  onTap: isHidden ? () => ref.read(karaokeProvider.notifier).revealWord(index) : null,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isActive ? 48 : 32,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isHidden ? Colors.blue : (isActive ? Colors.red : Colors.grey[800]),
                      decoration: isHidden ? TextDecoration.underline : TextDecoration.none,
                    ),
                    child: Text(isHidden ? "_____" : ts.word),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _audioPlayer.resume(),
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => _audioPlayer.pause(),
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () => _audioPlayer.seek(Duration.zero),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
