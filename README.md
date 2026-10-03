# 🌱 FarmHelper

### Offline AI-Powered Plant Disease Detection & Farming Assistant

FarmHelper is an **offline-first Flutter mobile application** designed to help farmers detect plant diseases and receive practical agricultural guidance directly on their Android device.

The application combines **on-device plant disease detection, an offline Gemma AI assistant, multilingual speech recognition, and offline text-to-speech** so that essential agricultural assistance can remain available even in areas with limited or no internet connectivity.

---

## 👥 Team

- **Ashmita Das**
- **Shivam Pandey**

---

# 📌 Problem Statement

Farmers often face difficulties identifying crop diseases at an early stage. Access to agricultural experts, reliable internet connectivity, and technical resources may be limited, particularly in rural areas.

Existing AI powered agricultural applications frequently depend on cloud services and continuous internet connectivity, making them less useful in low connectivity environments.

### The problem

> **How can we provide farmers with fast, accessible, intelligent plant disease assistance without depending on an internet connection?**

---

# 💡 Solution Overview

FarmHelper addresses this problem through an **offline AI architecture** that performs the core processing directly on the farmer's Android device.

The farmer can:

1. 📷 Capture or select an image of a plant.
2. 🌿 Select the crop.
3. 🤖 Run an on-device TensorFlow Lite model.
4. 📊 View the predicted disease and confidence score.
5. 💊 Receive disease-specific treatment and plant-care information.
6. 💬 Ask the offline **FarmHelper AI** questions.
7. 🎤 Ask questions using voice.
8. 🌐 Communicate in English, Hindi, or Tamil.
9. 🔊 Receive offline spoken responses where supported.
10. 📚 Access previous scan results through local history.

The AI pipeline is designed to operate **without requiring cloud AI APIs during application usage**.

---

# 🏗️ System Architecture

```text
                              ┌─────────────────────┐
                              │       FARMER        │
                              └──────────┬──────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    │                                         │
                    ▼                                         ▼
              📷 PLANT IMAGE                              🎤 VOICE
                    │                                         │
                    ▼                                         ▼
          ┌───────────────────┐                    ┌───────────────────┐
          │ Camera / Gallery  │                    │ Audio Recording   │
          └─────────┬─────────┘                    │ 16 kHz Mono WAV   │
                    │                              └─────────┬─────────┘
                    ▼                                        │
          ┌───────────────────┐                              ▼
          │ Image             │                    ┌───────────────────┐
          │ Preprocessing     │                    │ Whisper Tiny INT8 │
          │ 224 × 224 RGB     │                    │ Offline STT       │
          └─────────┬─────────┘                    └─────────┬─────────┘
                    │                                        │
                    ▼                                        ▼
          ┌───────────────────┐                         TEXT INPUT
          │ TensorFlow Lite   │                              │
          │ Disease Model     │                              │
          └─────────┬─────────┘                              │
                    │                                        │
                    ▼                                        ▼
          ┌───────────────────┐                    ┌───────────────────┐
          │ Disease           │                    │ Language          │
          │ + Confidence      │                    │ Detection         │
          └─────────┬─────────┘                    └─────────┬─────────┘
                    │                                        │
                    └────────────────┬───────────────────────┘
                                     │
                                     ▼
                         ┌────────────────────────┐
                         │   AI CONTEXT SERVICE   │
                         │                        │
                         │ Crop                   │
                         │ Disease                │
                         │ Confidence             │
                         └───────────┬────────────┘
                                     │
                                     ▼
                         ┌────────────────────────┐
                         │      GEMMA 3 1B        │
                         │        INT4             │
                         │                        │
                         │ Offline AI Assistant   │
                         │ Agricultural Guidance  │
                         └───────────┬────────────┘
                                     │
                         ┌───────────┴────────────┐
                         │                        │
                         ▼                        ▼
                  💬 TEXT RESPONSE             🔊 TTS
                                                  │
                                                  ▼
                                      ┌────────────────────┐
                                      │   Supertonic 3     │
                                      │      INT8          │
                                      │    Offline TTS     │
                                      └─────────┬──────────┘
                                                │
                                                ▼
                                           🔊 AUDIO


                    ┌─────────────────────────────────┐
                    │       ANDROID DEVICE            │
                    │                                 │
                    │  • TFLite Disease Models       │
                    │  • Gemma 3 1B Model             │
                    │  • Whisper Model                │
                    │  • Supertonic TTS Model         │
                    │  • Scan History                 │
                    │  • Application Data              │
                    └─────────────────────────────────┘

                         📵 OFFLINE-FIRST
                    No cloud AI required during use

---

# ⚙️ Setup

## Model files

The large model files are **not in Git** (see `.gitignore`). Put them here before building:

| Path | Source |
|------|--------|
| `assets/models/gemma3-1b-it-int4.task` | Gemma 3 1B IT int4 (litert-community on Hugging Face) |
| `assets/speech/whisper/tiny-encoder.int8.onnx`, `tiny-decoder.int8.onnx` | `sherpa-onnx-whisper-tiny.tar.bz2` (sherpa-onnx releases) |
| `assets/tts/supertonic/*.int8.onnx` | `sherpa-onnx-supertonic-3-tts-int8-2026-05-11.tar.bz2` (sherpa-onnx releases) |

Small files (`mango.tflite`, `grape.tflite`, `tiny-tokens.txt`, `tts.json`, `voice.bin`, `unicode_indexer.bin`) are committed.

## Build and install

```sh
flutter pub get
flutter build apk --release --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

The phone needs about **2.2 GB free**. The first time the AI chat opens, the Gemma model is copied into app storage (about 1 minute, shown as a percentage). After that it starts in a few seconds.

## Tests

```sh
flutter test
```
