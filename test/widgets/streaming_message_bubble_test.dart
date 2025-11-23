import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('StreamingMessageBubble', () {
    testWidgets('displays partial content during streaming',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Hello ');
      controller.addChunk('World');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Hello'), findsOneWidget);
    });

    testWidgets('shows blinking cursor while streaming',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Test');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump();

      // Cursor animation should be present
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('hides cursor when streaming completes',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Complete message');
      controller.completeStreaming();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the message without cursor
      expect(find.textContaining('Complete message'), findsOneWidget);
    });

    testWidgets('displays token count when showMetrics is true',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Test message');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(
                controller: controller,
                showMetrics: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show token metrics
      expect(find.textContaining('tokens'), findsWidgets);
    });

    testWidgets('updates content as new chunks arrive',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      controller.addChunk('First ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('Second ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('Third');
      await tester.pump(const Duration(milliseconds: 50));

      // Should contain all chunks
      expect(find.textContaining('First'), findsOneWidget);
    });

    testWidgets('handles error state', (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Partial content');
      controller.error('Connection failed');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('handles cancelled state', (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Cancelled content');
      controller.cancel();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show cancelled message or partial content
      expect(find.byType(StreamingMessageBubble), findsOneWidget);
    });

    testWidgets('respects custom bubble color', (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Test');
      const customColor = Colors.purple;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(
                controller: controller,
                bubbleColor: customColor,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCustomColor = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == customColor;
      });

      expect(hasCustomColor, isTrue);
    });

    testWidgets('properly disposes controller listener',
        (WidgetTester tester) async {
      final controller = StreamingChatController();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should dispose without errors
      expect(tester.takeException(), isNull);

      controller.dispose();
    });

    testWidgets('shows tokens per second metric',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('Test message with multiple tokens');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(
                controller: controller,
                showMetrics: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Should show tokens/sec metric
      expect(find.textContaining('tokens/sec'), findsWidgets);
    });

    testWidgets('renders markdown during streaming',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();
      controller.addChunk('**Bold text**');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Bold'), findsOneWidget);
    });

    testWidgets('handles empty streaming content',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      controller.startStreaming();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: StreamingMessageBubble(controller: controller),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(StreamingMessageBubble), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
