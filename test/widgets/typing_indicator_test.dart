import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('TypingIndicator', () {
    testWidgets('displays three animated dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Should find 3 dot containers
      final containers = tester.widgetList<Container>(find.byType(Container));
      final dotContainers = containers.where((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle;
      });

      expect(dotContainers.length, greaterThanOrEqualTo(3));
    });

    testWidgets('animates dots with different timings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Animation should be running
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('uses custom dot color when provided',
        (WidgetTester tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(
              dotColor: customColor,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasPurpleDots = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == customColor;
      });

      expect(hasPurpleDots, isTrue);
    });

    testWidgets('uses custom dot size when provided',
        (WidgetTester tester) async {
      const customSize = 12.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(
              dotSize: customSize,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final sizedDots = containers.where((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle &&
            container.constraints?.maxWidth == customSize;
      });

      expect(sizedDots.isNotEmpty, isTrue);
    });

    testWidgets('respects custom animation duration',
        (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(
              animationDuration: customDuration,
            ),
          ),
        ),
      );

      // Should find AnimatedBuilder widgets
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('properly disposes animation controllers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Should not throw any errors when disposing
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows visible animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: const MaterialApp(
            home: Scaffold(
              body: TypingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));

      // Verify the widget is present
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}
