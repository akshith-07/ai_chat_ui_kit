import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/streaming_state.dart';

/// Controller for handling streaming chat responses.
///
/// Manages streaming text from APIs, handles cancellation, buffering,
/// and provides callbacks for state changes.
///
/// Example:
/// ```dart
/// final controller = StreamingChatController(
///   onUpdate: (text) => setState(() => _streamedText = text),
///   onComplete: () => print('Streaming complete'),
/// );
/// controller.addText('Hello');
/// controller.addText(' World');
/// ```
class StreamingChatController extends ChangeNotifier {
  /// Creates a streaming chat controller.
  StreamingChatController({
    this.onUpdate,
    this.onComplete,
    this.onError,
    this.onCancel,
    this.bufferDelay = const Duration(milliseconds: 30),
  });

  /// Callback when streamed text is updated
  final void Function(String text)? onUpdate;

  /// Callback when streaming completes
  final VoidCallback? onComplete;

  /// Callback when an error occurs
  final void Function(String error)? onError;

  /// Callback when streaming is cancelled
  final VoidCallback? onCancel;

  /// Delay between character updates for smooth animation
  final Duration bufferDelay;

  String _streamedText = '';
  StreamingState _state = StreamingState.streaming;
  int _tokenCount = 0;
  DateTime? _startTime;
  Timer? _bufferTimer;
  final StringBuffer _buffer = StringBuffer();

  /// The current streamed text
  String get streamedText => _streamedText;

  /// The current streaming state
  StreamingState get state => _state;

  /// Number of tokens streamed
  int get tokenCount => _tokenCount;

  /// Tokens per second (generation speed)
  double get tokensPerSecond {
    if (_startTime == null) return 0.0;
    final Duration elapsed = DateTime.now().difference(_startTime!);
    if (elapsed.inMilliseconds == 0) return 0.0;
    return _tokenCount / (elapsed.inMilliseconds / 1000);
  }

  /// Adds text to the stream with buffering.
  void addText(String text) {
    if (_state != StreamingState.streaming) return;

    if (_startTime == null) {
      _startTime = DateTime.now();
    }

    _buffer.write(text);
    _tokenCount++;

    // Cancel existing timer and start new one
    _bufferTimer?.cancel();
    _bufferTimer = Timer(bufferDelay, _flushBuffer);
  }

  /// Flushes the buffer and updates the displayed text.
  void _flushBuffer() {
    if (_buffer.isEmpty) return;

    _streamedText += _buffer.toString();
    _buffer.clear();
    onUpdate?.call(_streamedText);
    notifyListeners();
  }

  /// Adds text immediately without buffering.
  void addTextImmediate(String text) {
    if (_state != StreamingState.streaming) return;

    if (_startTime == null) {
      _startTime = DateTime.now();
    }

    _streamedText += text;
    _tokenCount++;
    onUpdate?.call(_streamedText);
    notifyListeners();
  }

  /// Marks the streaming as complete.
  void complete() {
    _bufferTimer?.cancel();
    _flushBuffer(); // Flush any remaining buffered text
    _state = StreamingState.completed;
    onComplete?.call();
    notifyListeners();
  }

  /// Cancels the streaming.
  void cancel() {
    _bufferTimer?.cancel();
    _flushBuffer(); // Flush any remaining buffered text
    _state = StreamingState.cancelled;
    onCancel?.call();
    notifyListeners();
  }

  /// Sets an error state.
  void error(String message) {
    _bufferTimer?.cancel();
    _state = StreamingState.error;
    onError?.call(message);
    notifyListeners();
  }

  /// Resets the controller for a new streaming session.
  void reset() {
    _bufferTimer?.cancel();
    _buffer.clear();
    _streamedText = '';
    _state = StreamingState.streaming;
    _tokenCount = 0;
    _startTime = null;
    notifyListeners();
  }

  /// Checks if streaming is in progress.
  bool get isStreaming => _state == StreamingState.streaming;

  /// Checks if streaming is complete.
  bool get isComplete => _state == StreamingState.completed;

  /// Checks if streaming was cancelled.
  bool get isCancelled => _state == StreamingState.cancelled;

  /// Checks if an error occurred.
  bool get hasError => _state == StreamingState.error;

  @override
  void dispose() {
    _bufferTimer?.cancel();
    super.dispose();
  }
}
