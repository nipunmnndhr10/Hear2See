import 'package:flutter/material.dart';
import 'package:slf_teachable_model/services/sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SoundService _soundService = SoundService();
  String _label = "TAP TO MONITOR";
  bool _isCritical = false;
  bool _isRecording = false;
  bool _isVibrating = false;
  bool _isLocked = false; // The Lockout: ignores new sounds while true

  // Buffer to collect inferences before making a decision
  List<String> _inferenceBuffer = [];

  @override
  void initState() {
    super.initState();
    _soundService.loadModel();
  }

  // void _handleMicToggle() {
  //   if (_isRecording) {
  //     _soundService.stopListening();
  //     setState(() {
  //       _isRecording = false;
  //       _isCritical = false;
  //       _isVibrating = false;
  //       _label = "MONITORING STOPPED";
  //     });
  //   } else {
  //     setState(() {
  //       _isRecording = true;
  //       _label = "LISTENING...";
  //     });

  //     _soundService
  //         .startListening()
  //         .listen((event) async {
  //           final String result = event["recognitionResult"];
  //           final String threatType = _soundService.getThreatType(result);

  //           if (!mounted) return;

  //           setState(() {
  //             _label = result;
  //             _isCritical = (threatType != "none");
  //           });

  //           // Trigger vibrations only if a pattern isn't already running
  //           if (!_isVibrating && _isRecording) {
  //             if (threatType == "emergency") {
  //               _isVibrating = true;
  //               await _soundService.triggerEmergencyVibration();
  //               _isVibrating = false;
  //             } else if (threatType == "horn") {
  //               _isVibrating = true;
  //               await _soundService.triggerHornVibration();
  //               _isVibrating = false;
  //             }
  //           }
  //         })
  //         .onDone(() {
  //           if (mounted) setState(() => _isRecording = false);
  //         });
  //   }
  // }
  void _handleMicToggle() {
    if (_isRecording) {
      _soundService.stopListening();
      setState(() {
        _isRecording = false;
        _isCritical = false;
        _isLocked = false;
        _label = "STOPPED";
      });
    } else {
      setState(() {
        _isRecording = true;
        _label = "LISTENING...";
        _inferenceBuffer.clear();
      });

      _soundService.startListening().listen((event) async {
        if (_isLocked || !_isRecording)
          return; // IGNORE incoming audio during lockout

        final String result = event["recognitionResult"];
        _inferenceBuffer.add(result);

        // Wait until we have 3 samples to ensure we aren't "rushing"
        if (_inferenceBuffer.length >= 3) {
          // Find the most frequent label in our buffer (Simple Majority)
          String winner = _calculateWinner(_inferenceBuffer);
          _inferenceBuffer.clear(); // Clear for next round

          String threatType = _soundService.getThreatType(winner);

          if (threatType != "none") {
            await _triggerAlert(winner, threatType);
          } else {
            setState(() => _label = "ENVIRONMENT SAFE");
          }
        }
      });
    }
  }

  // Logic to find the most frequent classification in the buffer
  String _calculateWinner(List<String> buffer) {
    var counts = <String, int>{};
    for (var item in buffer) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // The alert cycle that locks the app
  Future<void> _triggerAlert(String label, String type) async {
    setState(() {
      _isLocked = true;
      _isCritical = true;
      _label = label;
    });

    // Execute the full vibration pattern (this "awaits" the 5-13 seconds)
    if (type == "emergency") {
      await _soundService.triggerEmergencyVibration();
    } else if (type == "horn") {
      await _soundService.triggerHornVibration();
    }

    // Cooldown: After vibrations, keep it locked/alert for 2 more seconds if desired
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLocked = false;
        _isCritical = false;
        _label = "LISTENING...";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI remains identical but reacts to the _isLocked and _isCritical states
    return Scaffold(
      backgroundColor: _isCritical ? Colors.red[900] : Colors.black,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isCritical
              ? RadialGradient(colors: [Colors.red, Colors.red[900]!])
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCritical ? Colors.yellow : Colors.white10,
              ),
              child: Icon(
                _isCritical ? Icons.warning_amber_rounded : Icons.graphic_eq,
                size: 80,
                color: _isCritical ? Colors.black : Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isLocked
                  ? "ALERT ACTIVE - PAUSED"
                  : (_isRecording ? "SCANNING..." : "TAP TO START"),
              style: TextStyle(
                color: _isCritical ? Colors.yellow : Colors.white54,
              ),
            ),
            const SizedBox(height: 100),
            GestureDetector(
              onTap: _handleMicToggle,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _isRecording
                    ? Colors.redAccent
                    : Colors.blueAccent,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
