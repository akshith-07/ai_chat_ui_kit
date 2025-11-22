import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

/// Displays a formatted timestamp for chat messages.
///
/// Supports both relative (e.g., "2m ago") and absolute time formats.
///
/// Example:
/// ```dart
/// MessageTimestamp(
///   timestamp: DateTime.now(),
///   isRelative: true,
/// )
/// ```
class MessageTimestamp extends StatelessWidget {
  /// Creates a message timestamp widget.
  const MessageTimestamp({
    required this.timestamp,
    this.isRelative = true,
    this.color,
    this.fontSize = 12.0,
    super.key,
  });

  /// The timestamp to display
  final DateTime timestamp;

  /// Whether to use relative time format (e.g., "2m ago")
  final bool isRelative;

  /// Color of the timestamp text
  final Color? color;

  /// Font size of the timestamp
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final String formattedTime =
        isRelative
            ? TimeFormatter.formatRelative(timestamp)
            : TimeFormatter.formatAbsolute(timestamp);

    return Text(
      formattedTime,
      style: TextStyle(
        color: color ?? Colors.black54,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
