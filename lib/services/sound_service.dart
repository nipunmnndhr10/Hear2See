import 'package:tflite_audio/tflite_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  // Teachable Machine standard audio configurations
  final double threshold = 0.3;
  final int sampleRate = 44100;
  final int bufferSize = 22016;

  Future<void> loadModel() async {
    try {
      await TfliteAudio.loadModel(
        model: 'assets/soundclassifier3.tflite',
        label: 'assets/labels.txt',
        inputType: 'rawAudio',
        numThreads: 1,
        isAsset: true,
      );
    } catch (e) {
      debugPrint("Model Load Error: $e");
    }
  }

  Stream<dynamic> startListening() {
    return TfliteAudio.startAudioRecognition(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
      detectionThreshold: threshold,
      numOfInferences: 10000,
      averageWindowDuration: 1000,
      minimumTimeBetweenSamples: 500,
      suppressionTime: 1500,
    );
  }

  void stopListening() {
    TfliteAudio.stopAudioRecognition();
  }

  void triggerVibration() {
    Vibration.vibrate(duration: 800, amplitude: 255);
  }

  bool isCriticalSound(String label) {
    final cleanLabel = label.toLowerCase();
    return cleanLabel.contains("ambulance") ||
        cleanLabel.contains("car horn") ||
        cleanLabel.contains("firefighter");
  }
}
