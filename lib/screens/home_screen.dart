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

  @override
  void initState() {
    super.initState();
    _soundService.loadModel(); // Pre-load model on app start
  }

  void _handleMicToggle() {
    if (_isRecording) {
      _soundService.stopListening();
      setState(() {
        _isRecording = false;
        _isCritical = false;
        _label = "MONITORING STOPPED";
      });
    } else {
      setState(() {
        _isRecording = true;
        _label = "LISTENING...";
      });

      _soundService
          .startListening()
          .listen((event) {
            final String result = event["recognitionResult"];
            final bool danger = _soundService.isCriticalSound(result);

            setState(() {
              _label = result;
              _isCritical = danger;
            });

            if (danger) {
              _soundService.triggerVibration();
            }
          })
          .onDone(() {
            setState(() => _isRecording = false);
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
          // Adds a slight glow effect when critical
          gradient: _isCritical
              ? RadialGradient(colors: [Colors.red, Colors.red[900]!])
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Alert Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCritical ? Colors.yellow : Colors.white10,
              ),
              child: Icon(
                _isCritical ? Icons.warning_rounded : Icons.graphic_eq,
                size: 80,
                color: _isCritical ? Colors.black : Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 40),

            // Detection Text
            Text(
              _label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 10),
            Text(
              _isCritical ? "DANGER DETECTED" : "SCANNING ENVIRONMENT",
              style: TextStyle(
                color: _isCritical ? Colors.yellow : Colors.white54,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 80),

            // Mic Button
            GestureDetector(
              onTap: _handleMicToggle,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: _isRecording
                    ? Colors.redAccent
                    : Colors.blueAccent,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
