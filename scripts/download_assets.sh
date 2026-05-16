#!/bin/bash

# Configuration
ASSETS_DIR="assets"
MODELS_DIR="$ASSETS_DIR/models"
AUDIO_DIR="$ASSETS_DIR/test_audio"

# Create directories
mkdir -p "$MODELS_DIR" "$AUDIO_DIR"

echo "--- Downloading Test Audio ---"
SONG_URL="https://archive.org/download/lp_french-songs-for-children_catherine-clouzot-jacques-rousseau/disc1/01.09.%20Fr%C3%A8re%20Jacques.mp3"
curl -L "$SONG_URL" -o "$AUDIO_DIR/frere_jacques.mp3"

echo "--- Downloading Whisper Tiny (ONNX) ---"
WHISPER_BASE="https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny/resolve/main"
curl -L "$WHISPER_BASE/tiny-encoder.onnx" -o "$MODELS_DIR/whisper-tiny-encoder.onnx"
curl -L "$WHISPER_BASE/tiny-decoder.onnx" -o "$MODELS_DIR/whisper-tiny-decoder.onnx"
curl -L "$WHISPER_BASE/tiny-tokens.txt" -o "$MODELS_DIR/whisper-tiny-tokens.txt"

echo "--- Downloading Qwen 1.5B (GGUF) ---"
QWEN_URL="https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
# Note: 1GB file, might take time. Using -C - to allow resume.
curl -L -C - "$QWEN_URL" -o "$MODELS_DIR/qwen2.5-1.5b-instruct-q4_k_m.gguf"

echo "--- Asset Download Complete ---"
ls -lh "$MODELS_DIR" "$AUDIO_DIR"
