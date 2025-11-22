import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('TimeFormatter', () {
    test('formatRelative returns "Just now" for recent timestamps', () {
      final DateTime now = DateTime.now();
      final DateTime recent = now.subtract(const Duration(seconds: 30));

      expect(TimeFormatter.formatRelative(recent), equals('Just now'));
    });

    test('formatRelative returns minutes for timestamps within an hour', () {
      final DateTime now = DateTime.now();
      final DateTime tenMinutesAgo = now.subtract(const Duration(minutes: 10));

      expect(TimeFormatter.formatRelative(tenMinutesAgo), equals('10m ago'));
    });

    test('formatRelative returns hours for timestamps within a day', () {
      final DateTime now = DateTime.now();
      final DateTime twoHoursAgo = now.subtract(const Duration(hours: 2));

      expect(TimeFormatter.formatRelative(twoHoursAgo), equals('2h ago'));
    });

    test('formatRelative returns "Yesterday" for yesterday', () {
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(const Duration(days: 1));

      expect(TimeFormatter.formatRelative(yesterday), equals('Yesterday'));
    });

    test('formatRelative returns days for timestamps within a week', () {
      final DateTime now = DateTime.now();
      final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));

      expect(TimeFormatter.formatRelative(threeDaysAgo), equals('3d ago'));
    });

    test('formatDateSeparator returns "Today" for today', () {
      final DateTime today = DateTime.now();

      expect(TimeFormatter.formatDateSeparator(today), equals('Today'));
    });

    test('formatDateSeparator returns "Yesterday" for yesterday', () {
      final DateTime yesterday =
          DateTime.now().subtract(const Duration(days: 1));

      expect(
        TimeFormatter.formatDateSeparator(yesterday),
        equals('Yesterday'),
      );
    });

    test('isDifferentDay returns true for different days', () {
      final DateTime today = DateTime.now();
      final DateTime yesterday = today.subtract(const Duration(days: 1));

      expect(TimeFormatter.isDifferentDay(today, yesterday), isTrue);
    });

    test('isDifferentDay returns false for same day', () {
      final DateTime morning = DateTime(2025, 1, 1, 9, 0);
      final DateTime evening = DateTime(2025, 1, 1, 18, 0);

      expect(TimeFormatter.isDifferentDay(morning, evening), isFalse);
    });
  });
}
