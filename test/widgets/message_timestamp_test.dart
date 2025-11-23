import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('MessageTimestamp', () {
    testWidgets('displays relative time for recent timestamps',
        (WidgetTester tester) async {
      final recentTime = DateTime.now().subtract(const Duration(minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: recentTime),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      // Should show something like "5m ago"
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, contains('ago'));
    });

    testWidgets('displays absolute time when useRelativeTime is false',
        (WidgetTester tester) async {
      final testTime = DateTime(2025, 1, 15, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(
              timestamp: testTime,
              useRelativeTime: false,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      // Should show formatted absolute time
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });

    testWidgets('uses custom text style when provided',
        (WidgetTester tester) async {
      final testTime = DateTime.now();
      const customStyle = TextStyle(
        fontSize: 14,
        color: Colors.purple,
        fontStyle: FontStyle.italic,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(
              timestamp: testTime,
              style: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, customStyle.fontSize);
      expect(textWidget.style?.color, customStyle.color);
      expect(textWidget.style?.fontStyle, customStyle.fontStyle);
    });

    testWidgets('shows "Just now" for very recent messages',
        (WidgetTester tester) async {
      final justNow = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: justNow),
          ),
        ),
      );

      expect(find.textContaining('now'), findsOneWidget);
    });

    testWidgets('shows minutes ago for timestamps within last hour',
        (WidgetTester tester) async {
      final minutesAgo = DateTime.now().subtract(const Duration(minutes: 45));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: minutesAgo),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, contains('m'));
    });

    testWidgets('shows hours ago for older timestamps',
        (WidgetTester tester) async {
      final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: hoursAgo),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, contains('h'));
    });

    testWidgets('renders with ChatTheme styling',
        (WidgetTester tester) async {
      final testTime = DateTime.now();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.dark(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageTimestamp(timestamp: testTime),
            ),
          ),
        ),
      );

      expect(find.byType(MessageTimestamp), findsOneWidget);
    });

    testWidgets('handles future timestamps gracefully',
        (WidgetTester tester) async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: futureTime),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(MessageTimestamp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('updates when timestamp changes',
        (WidgetTester tester) async {
      final time1 = DateTime.now().subtract(const Duration(minutes: 5));
      final time2 = DateTime.now().subtract(const Duration(hours: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: time1),
          ),
        ),
      );

      final firstText = tester.widget<Text>(find.byType(Text)).data;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTimestamp(timestamp: time2),
          ),
        ),
      );

      final secondText = tester.widget<Text>(find.byType(Text)).data;

      expect(firstText, isNot(equals(secondText)));
    });
  });
}
