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

  @override
  void initState() {
    super.initState();
    _soundService.loadModel();
  }

  void _handleMicToggle() {
    if (_isRecording) {
      _soundService.stopListening();
      setState(() {
        _isRecording = false;
        _isCritical = false;
        _isVibrating = false;
        _label = "MONITORING STOPPED";
      });
    } else {
      setState(() {
        _isRecording = true;
        _label = "LISTENING...";
      });

      _soundService
          .startListening()
          .listen((event) async {
            final String result = event["recognitionResult"];
            final String threatType = _soundService.getThreatType(result);

            if (!mounted) return;

            setState(() {
              _label = result;
              _isCritical = (threatType != "none");
            });

            // Trigger vibrations only if a pattern isn't already running
            if (!_isVibrating && _isRecording) {
              if (threatType == "emergency") {
                _isVibrating = true;
                await _soundService.triggerEmergencyVibration();
                _isVibrating = false;
              } else if (threatType == "horn") {
                _isVibrating = true;
                await _soundService.triggerHornVibration();
                _isVibrating = false;
              }
            }
          })
          .onDone(() {
            if (mounted) setState(() => _isRecording = false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _isCritical ? "DANGER DETECTED" : "SCANNING FOR SIRENS",
              style: TextStyle(
                color: _isCritical ? Colors.yellow : Colors.white54,
                letterSpacing: 1.2,
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
