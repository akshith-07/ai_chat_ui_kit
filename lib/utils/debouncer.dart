import 'dart:async';

/// A utility class that delays function execution until after a specified duration.
///
/// Useful for optimizing performance by preventing excessive function calls,
/// such as during text input or search operations.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
/// debouncer.run(() {
///   // This will only execute 500ms after the last call
///   performSearch(query);
/// });
/// ```
class Debouncer {
  /// Creates a debouncer with the specified delay duration.
  Debouncer({required this.milliseconds});

  /// The delay duration in milliseconds
  final int milliseconds;

  Timer? _timer;

  /// Runs the provided action after the debounce duration.
  ///
  /// If called again before the duration expires, the previous call is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending debounced action.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending actions.
  void dispose() {
    _timer?.cancel();
  }
}
