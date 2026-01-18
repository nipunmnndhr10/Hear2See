import 'package:tflite_audio/tflite_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final double threshold = 0.4;
  final int sampleRate = 44100;
  final int bufferSize = 22016;

  // Flag to kill vibration loops immediately
  bool _shouldContinueVibrating = true;

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
    _shouldContinueVibrating = true; // Reset flag when starting
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
    _shouldContinueVibrating = false; // Stop the logic loops
    Vibration.cancel(); // Stop the physical motor immediately
  }

  // Pattern: 3.5s pulse, 1s gap, repeated 3 times
  Future<void> triggerEmergencyVibration() async {
    for (int i = 0; i < 3; i++) {
      if (!_shouldContinueVibrating) return; // Exit if stopped
      Vibration.vibrate(duration: 3500, amplitude: 700);
      await Future.delayed(const Duration(milliseconds: 4500));
    }
  }

  // Pattern: 0.3s short burst, 1s gap, repeated 3 times
  // Future<void> triggerHornVibration() async {
  //   for (int i = 0; i < 3; i++) {
  //     if (!_shouldContinueVibrating) return; // Exit if stopped
  //     Vibration.vibrate(duration: 300, amplitude: 255);
  //     await Future.delayed(const Duration(milliseconds: 1300));
  //   }
  // }
  Future<void> triggerHornVibration() async {
    // Loop for 4 "Sets"
    for (int set = 0; set < 4; set++) {
      if (!_shouldContinueVibrating) return;

      // Inner loop: 3 "Super Fast" vibrations per set
      for (int quick = 0; quick < 3; quick++) {
        if (!_shouldContinueVibrating) return;

        Vibration.vibrate(duration: 50, amplitude: 255); // Super short pulse
        // 100ms gap between pulses within a set
        await Future.delayed(const Duration(milliseconds: 150));
      }

      // 1 second gap between sets
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  String getThreatType(String label) {
    final cleanLabel = label.toLowerCase();
    if (cleanLabel.contains("ambulance") ||
        cleanLabel.contains("firefighter")) {
      return "emergency";
    } else if (cleanLabel.contains("car horn")) {
      return "horn";
    }
    return "none";
  }
}
