import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

/// A horizontal date separator for the message list.
///
/// Displays dates like "Today", "Yesterday", or "January 15, 2025".
///
/// Example:
/// ```dart
/// DateSeparator(
///   date: DateTime.now(),
/// )
/// ```
class DateSeparator extends StatelessWidget {
  /// Creates a date separator.
  const DateSeparator({
    required this.date,
    this.textColor,
    this.backgroundColor,
    this.fontSize = 12.0,
    super.key,
  });

  /// The date to display
  final DateTime date;

  /// Color of the date text
  final Color? textColor;

  /// Background color of the separator badge
  final Color? backgroundColor;

  /// Font size of the date text
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final String formattedDate = TimeFormatter.formatDateSeparator(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: textColor ?? Colors.black87,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
