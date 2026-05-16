# Karaok’IA - Project Documentation

## Overview
Karaok’IA is an educational AI karaoke application for children, built with Flutter. It processes audio files locally to synchronize text and generate educational games like "Missing Words".

## Architecture
- **Frontend:** Flutter + Riverpod.
- **Audio:** `audioplayers` for sync playback.
- **ASR (Speech-To-Text):** `sherpa_onnx` for on-device transcription with word-level timestamps.
- **LLM (Logic):** `llama_cpp_dart` running a TinyLLM (Qwen2.5 1.5B) for educational content generation.
- **Local-First:** All models run natively on the device (Android/iOS/Android TV).

## Required Models
To run the full AI pipeline, download the following models into the app's document directory (handled by `ModelManager`):
1. **ASR:** Whisper Tiny (ONNX format) - encoder, decoder, and tokens.
2. **LLM:** Qwen2.5-1.5B-Instruct-Q4_K_M.gguf.

## Key Features
- **Karaoke Sync:** Words light up as the song plays.
- **Missing Word Game:** AI hides educationally relevant words for the child to find or guess.
- **Family Cast:** Support for streaming the experience to a TV.
