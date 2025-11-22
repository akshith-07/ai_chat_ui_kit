import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// A button widget for voice input with recording animation.
///
/// Integrates with speech-to-text services and handles permissions.
///
/// Example:
/// ```dart
/// VoiceInputButton(
///   onTextRecognized: (text) => print('Recognized: $text'),
///   color: Colors.blue,
/// )
/// ```
class VoiceInputButton extends StatefulWidget {
  /// Creates a voice input button.
  const VoiceInputButton({
    required this.onTextRecognized,
    this.color,
    this.size = 24.0,
    this.onRecordingStateChanged,
    super.key,
  });

  /// Callback when text is recognized
  final void Function(String text) onTextRecognized;

  /// Color of the microphone icon
  final Color? color;

  /// Size of the icon
  final double size;

  /// Callback when recording state changes
  final void Function(bool isRecording)? onRecordingStateChanged;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    // Request microphone permission
    final PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
          ),
        );
      }
      return;
    }

    // Initialize speech recognition
    final bool available = await _speech.initialize(
      onStatus: (String status) {
        if (status == 'done' || status == 'notListening') {
          _stopListening();
        }
      },
      onError: (dynamic error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
            ),
          );
        }
        _stopListening();
      },
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    widget.onRecordingStateChanged?.call(true);

    await _speech.listen(
      onResult: (stt.SpeechRecognitionResult result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });

    widget.onRecordingStateChanged?.call(false);

    if (_recognizedText.isNotEmpty) {
      widget.onTextRecognized(_recognizedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isListening) {
      return GestureDetector(
        onTap: _toggleListening,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) =>
              Container(
            width: widget.size * 2,
            height: widget.size * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.color ?? Colors.red).withOpacity(
                0.2 + (_animationController.value * 0.3),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.mic,
                size: widget.size,
                color: widget.color ?? Colors.red,
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        Icons.mic_none,
        size: widget.size,
        color: widget.color,
      ),
      onPressed: _toggleListening,
    );
  }
}
