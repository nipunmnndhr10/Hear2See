// import 'package:flutter/material.dart';
// import 'package:tflite_audio/tflite_audio.dart';
// import 'package:vibration/vibration.dart';

// void main() => runApp(
//   const MaterialApp(debugShowCheckedModeBanner: false, home: SoundAlertMVP()),
// );

// class SoundAlertMVP extends StatefulWidget {
//   const SoundAlertMVP({super.key});

//   @override
//   State<SoundAlertMVP> createState() => _SoundAlertMVPState();
// }

// class _SoundAlertMVPState extends State<SoundAlertMVP> {
//   String _label = "Listening...";
//   String _confidence = "0%";
//   bool _isCritical = false;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _initModel();
//   }

//   // 1. Load the Teachable Machine Model
//   Future<void> _initModel() async {
//     try {
//       await TfliteAudio.loadModel(
//         model: 'assets/soundclassifier3.tflite',
//         label: 'assets/labels.txt',
//         inputType: 'rawAudio', // Mandatory for TM models
//         numThreads: 1,
//         isAsset: true,
//       );
//     } catch (e) {
//       debugPrint("Load Error: $e");
//     }
//   }

//   // 2. Start Continuous Recognition
//   void _startListening() {
//     setState(() => _isRecording = true);

//     // TM standard parameters: sampleRate 44100, bufferSize 22016
//     TfliteAudio.startAudioRecognition(
//           sampleRate: 44100,
//           bufferSize: 22016,
//           detectionThreshold: 0.3, // ← lower = more sensitive
//           numOfInferences:
//               1000, // ← VERY IMPORTANT — make it loop more than once!
//           averageWindowDuration: 1000, // ms — helps smooth results
//           minimumTimeBetweenSamples: 500,
//           suppressionTime: 1500, // Adjust this for sensitivity
//         )
//         .listen((event) {
//           final String result = event["recognitionResult"];
//           // Logic to check if the detected sound is one of your critical labels
//           final bool criticalDetected =
//               result.toLowerCase().contains("ambulance") ||
//               result.toLowerCase().contains("car horn") ||
//               result.toLowerCase().contains("firefighter");

//           setState(() {
//             _label = result;
//             _isCritical = criticalDetected;
//           });

//           // 3. Trigger Vibration for Critical Sounds
//           if (criticalDetected) {
//             Vibration.vibrate(duration: 800, amplitude: 255);
//           }
//         })
//         .onDone(() {
//           setState(() => _isRecording = false);
//           print("Stream ended naturally"); // ← for debugging
//         });
//   }

//   void _stopListening() {
//     TfliteAudio.stopAudioRecognition();
//     setState(() => _isRecording = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Visual Alert: Red background on danger
//       backgroundColor: _isCritical ? Colors.red[900] : Colors.grey[900],
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _isCritical ? Icons.warning_amber_rounded : Icons.graphic_eq,
//               size: 100,
//               color: Colors.white,
//             ),
//             const SizedBox(height: 30),
//             Text(
//               _label.toUpperCase(),
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _isCritical ? "DANGER DETECTED" : "Environment Safe",
//               style: TextStyle(
//                 color: _isCritical ? Colors.yellow : Colors.greenAccent,
//                 fontSize: 18,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 60),
//             Center(
//               child: GestureDetector(
//                 onTap: _isRecording ? _stopListening : _startListening,
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundColor: _isRecording
//                       ? Colors.orange
//                       : Colors.blueAccent,
//                   child: Icon(
//                     _isRecording ? Icons.stop : Icons.mic,
//                     color: Colors.white,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _isRecording ? "Tap to Stop" : "Tap to Monitor",
//               style: const TextStyle(color: Colors.white54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:slf_teachable_model/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Hear2See());
}

class Hear2See extends StatelessWidget {
  const Hear2See({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIDEA Sound Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}
