import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('DateSeparator', () {
    testWidgets('displays formatted date', (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(date: testDate),
          ),
        ),
      );

      // Should display "Today", "Yesterday", or formatted date
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays "Today" for current date',
        (WidgetTester tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(date: today),
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('displays "Yesterday" for previous day',
        (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(date: yesterday),
          ),
        ),
      );

      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('uses custom text style when provided',
        (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);
      const customStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(
              date: testDate,
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, customStyle.fontSize);
      expect(textWidget.style?.fontWeight, customStyle.fontWeight);
      expect(textWidget.style?.color, customStyle.color);
    });

    testWidgets('uses custom background color when provided',
        (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);
      const customColor = Colors.amber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(
              date: testDate,
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCustomBackground = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == customColor;
      });

      expect(hasCustomBackground, isTrue);
    });

    testWidgets('respects custom padding', (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);
      const customPadding = EdgeInsets.all(24.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(
              date: testDate,
              padding: customPadding,
            ),
          ),
        ),
      );

      final paddingWidget =
          tester.widget<Padding>(find.byType(Padding).first);
      expect(paddingWidget.padding, customPadding);
    });

    testWidgets('renders with theme from ChatThemeProvider',
        (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.dark(),
          child: MaterialApp(
            home: Scaffold(
              body: DateSeparator(date: testDate),
            ),
          ),
        ),
      );

      expect(find.byType(DateSeparator), findsOneWidget);
    });

    testWidgets('has center alignment', (WidgetTester tester) async {
      final testDate = DateTime(2025, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateSeparator(date: testDate),
          ),
        ),
      );

      final centerWidget = find.byType(Center);
      expect(centerWidget, findsOneWidget);
    });
  });
}
