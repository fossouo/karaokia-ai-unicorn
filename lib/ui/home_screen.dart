import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../providers/karaoke_provider.dart';
import '../providers/service_providers.dart';
import '../services/transcription_service.dart';
import 'karaoke_player.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> _availableSongs = const [
    {
      'title': 'Frère Jacques',
      'path': 'assets/test_audio/frere_jacques.mp3',
    },
    {
      'title': 'GIMS - PARISIENNE',
      'path': 'assets/test_audio/GIMS & La Mano 1.9 - PARISIENNE (Clip officiel).mp3',
    },
  ];

  Future<void> _pickAndProcess(BuildContext context, WidgetRef ref) async {
    fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(type: fp.FileType.audio);

    if (result != null) {
      String path = result.files.single.path!;
      ref.read(karaokeProvider.notifier).setAudioPath(path);

      try {
        final remoteAi = ref.read(remoteAiServiceProvider);
        final timestamps = await remoteAi.transcribe(path);
        final hidden = await remoteAi.identifyMissingWords(timestamps);

        ref.read(karaokeProvider.notifier).setTimestamps(timestamps);
        ref.read(karaokeProvider.notifier).setHiddenIndices(hidden);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur d\'analyse : $e')),
          );
        }
        ref.read(karaokeProvider.notifier).setAudioPath(""); // Reset
      }
    }
  }

  Future<void> _selectSong(BuildContext context, WidgetRef ref, String path, String title) async {
    ref.read(karaokeProvider.notifier).setAudioPath(path);
    
    // Simulation de transcription adaptée selon la chanson
    await Future.delayed(const Duration(seconds: 1));
    
    List<WordTimestamp> timestamps;
    List<int> hidden;

    if (title == 'Frère Jacques') {
      timestamps = [
        WordTimestamp(word: "Frère", start: 0.5, end: 1.0),
        WordTimestamp(word: "Jacques,", start: 1.1, end: 1.8),
        WordTimestamp(word: "Frère", start: 2.0, end: 2.5),
        WordTimestamp(word: "Jacques,", start: 2.6, end: 3.3),
        WordTimestamp(word: "Dormez-vous ?", start: 3.5, end: 4.8),
        WordTimestamp(word: "Dormez-vous ?", start: 5.0, end: 6.3),
        WordTimestamp(word: "Sonez", start: 6.5, end: 7.0),
        WordTimestamp(word: "les", start: 7.1, end: 7.3),
        WordTimestamp(word: "matines,", start: 7.4, end: 8.2),
        WordTimestamp(word: "Sonez", start: 8.4, end: 8.9),
        WordTimestamp(word: "les", start: 9.0, end: 9.2),
        WordTimestamp(word: "matines,", start: 9.3, end: 10.1),
        WordTimestamp(word: "Ding,", start: 10.3, end: 10.8),
        WordTimestamp(word: "dang,", start: 10.9, end: 11.4),
        WordTimestamp(word: "dong !", start: 11.5, end: 12.2),
        WordTimestamp(word: "Ding,", start: 12.4, end: 12.9),
        WordTimestamp(word: "dang,", start: 13.0, end: 13.5),
        WordTimestamp(word: "dong !", start: 13.6, end: 14.3),
      ];
      hidden = [4, 12, 14];
    } else if (title.contains('PARISIENNE')) {
      // Mock ajusté pour GIMS - PARISIENNE (Refrain)
      timestamps = [
        WordTimestamp(word: "J'suis", start: 14.5, end: 14.8),
        WordTimestamp(word: "une", start: 14.9, end: 15.1),
        WordTimestamp(word: "parisienne,", start: 15.2, end: 16.2),
        WordTimestamp(word: "j'aime", start: 16.5, end: 16.8),
        WordTimestamp(word: "trop", start: 16.9, end: 17.2),
        WordTimestamp(word: "la", start: 17.3, end: 17.4),
        WordTimestamp(word: "vie", start: 17.5, end: 18.2),
        WordTimestamp(word: "parisienne.", start: 18.3, end: 19.5),
        
        WordTimestamp(word: "J'suis", start: 19.8, end: 20.1),
        WordTimestamp(word: "une", start: 20.2, end: 20.4),
        WordTimestamp(word: "parisienne,", start: 20.5, end: 21.5),
        WordTimestamp(word: "j'aime", start: 21.8, end: 22.1),
        WordTimestamp(word: "trop", start: 22.2, end: 22.5),
        WordTimestamp(word: "la", start: 22.6, end: 22.7),
        WordTimestamp(word: "vie", start: 22.8, end: 23.5),
        WordTimestamp(word: "parisienne.", start: 23.6, end: 24.8),
      ];
      hidden = [2, 10]; // Cache "parisienne"
    } else {
      // Mock générique pour d'autres chansons en attendant Whisper
      timestamps = [
        WordTimestamp(word: "Nouvelle", start: 0.5, end: 1.5),
        WordTimestamp(word: "chanson", start: 1.6, end: 2.5),
        WordTimestamp(word: "détectée", start: 2.6, end: 4.0),
      ];
      hidden = [1];
    }
    
    ref.read(karaokeProvider.notifier).setTimestamps(timestamps);
    ref.read(karaokeProvider.notifier).setHiddenIndices(hidden);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karaokeState = ref.watch(karaokeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karaok’IA'),
        actions: [
          if (karaokeState.audioPath != null)
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () => ref.read(karaokeProvider.notifier).setAudioPath(""), // Retour à la liste
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (karaokeState.audioPath == null || karaokeState.audioPath == "")
              Expanded(
                child: ListView.builder(
                  itemCount: _availableSongs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _availableSongs.length) {
                      return ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Utiliser une chanson locale'),
                        subtitle: const Text('Analyse via Xeon AI Infrastructure'),
                        onTap: () => _pickAndProcess(context, ref),
                      );
                    }
                    final song = _availableSongs[index];
                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(song['title']!),
                      subtitle: const Text('Niveau : Débutant'),
                      onTap: () => _selectSong(context, ref, song['path']!, song['title']!),
                    );
                  },
                ),
              )
            else if (karaokeState.isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyse de la chanson en cours...'),
                ],
              )
            else
              const Expanded(child: KaraokePlayer()),
          ],
        ),
      ),
    );
  }
}
