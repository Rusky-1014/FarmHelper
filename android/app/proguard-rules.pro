# MediaPipe (Gemma inference) - its Java classes are called from native code.
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Protocol Buffers used by MediaPipe
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# TensorFlow Lite (leaf disease models)
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# sherpa-onnx (offline speech)
-keep class com.k2fsa.sherpa.onnx.** { *; }
