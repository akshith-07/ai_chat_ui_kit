import 'package:intl/intl.dart';

/// Utility class for formatting timestamps in chat messages.
///
/// Provides both relative (e.g., "2m ago") and absolute time formatting.
class TimeFormatter {
  /// Private constructor to prevent instantiation
  TimeFormatter._();

  /// Formats a timestamp as a relative time string.
  ///
  /// Examples:
  /// - Just now
  /// - 2m ago
  /// - 1h ago
  /// - Yesterday
  /// - 3d ago
  /// - Jan 15
  static String formatRelative(DateTime timestamp) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (timestamp.year == now.year) {
      return DateFormat('MMM d').format(timestamp);
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  /// Formats a timestamp as an absolute time string.
  ///
  /// Example: "Jan 15, 2025 at 2:30 PM"
  static String formatAbsolute(DateTime timestamp) =>
      DateFormat('MMM d, yyyy \'at\' h:mm a').format(timestamp);

  /// Formats a timestamp for display in chat bubbles.
  ///
  /// Shows time for today's messages, date for older messages.
  ///
  /// Examples:
  /// - "2:30 PM" (today)
  /// - "Yesterday 2:30 PM"
  /// - "Jan 15, 2:30 PM" (this year)
  /// - "Jan 15, 2025" (previous years)
  static String formatChatTimestamp(DateTime timestamp) {
    final DateTime now = DateTime.now();
    final bool isToday = timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;

    if (isToday) {
      return DateFormat('h:mm a').format(timestamp);
    }

    final bool isYesterday = timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day - 1;

    if (isYesterday) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    }

    if (timestamp.year == now.year) {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }

    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  /// Formats a date for use as a date separator in the chat.
  ///
  /// Examples:
  /// - "Today"
  /// - "Yesterday"
  /// - "January 15, 2025"
  static String formatDateSeparator(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMMM d').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  /// Returns true if two timestamps are on different days.
  static bool isDifferentDay(DateTime timestamp1, DateTime timestamp2) {
    final DateTime date1 =
        DateTime(timestamp1.year, timestamp1.month, timestamp1.day);
    final DateTime date2 =
        DateTime(timestamp2.year, timestamp2.month, timestamp2.day);
    return !date1.isAtSameMomentAs(date2);
  }
}
