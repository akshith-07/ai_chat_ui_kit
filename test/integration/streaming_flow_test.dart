import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('Streaming Chat Flow Integration Tests', () {
    testWidgets('complete streaming message flow with chunks',
        (WidgetTester tester) async {
      final controller = StreamingChatController();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: StreamingMessageBubble(
                      controller: controller,
                      showMetrics: true,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.startStreaming();
                      controller.addChunk('Hello ');
                      Future.delayed(const Duration(milliseconds: 50), () {
                        controller.addChunk('World');
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        controller.completeStreaming();
                      });
                    },
                    child: const Text('Start Streaming'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Step 1: Start streaming
      await tester.tap(find.text('Start Streaming'));
      await tester.pump();

      // Step 2: Verify first chunk appears
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.textContaining('Hello'), findsOneWidget);

      // Step 3: Verify second chunk appears
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.textContaining('World'), findsOneWidget);

      // Step 4: Verify streaming completes
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.state, StreamingState.completed);

      controller.dispose();
    });

    testWidgets('streaming cancellation flow works correctly',
        (WidgetTester tester) async {
      final controller = StreamingChatController();
      bool cancelled = false;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: StreamingMessageBubble(
                      controller: controller,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.startStreaming();
                          controller.addChunk('Streaming content...');
                        },
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.cancel();
                          cancelled = true;
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Start streaming
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(controller.state, StreamingState.streaming);

      // Cancel streaming
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
      expect(controller.state, StreamingState.cancelled);

      controller.dispose();
    });

    testWidgets('streaming error handling displays error message',
        (WidgetTester tester) async {
      final controller = StreamingChatController();

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: StreamingMessageBubble(
                      controller: controller,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.startStreaming();
                      controller.addChunk('Partial content');
                      Future.delayed(const Duration(milliseconds: 50), () {
                        controller.error('Connection timeout');
                      });
                    },
                    child: const Text('Trigger Error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Error'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.state, StreamingState.error);
      expect(find.textContaining('Error'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('streaming with token metrics updates correctly',
        (WidgetTester tester) async {
      final controller = StreamingChatController();

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

      controller.startStreaming();
      controller.addChunk('Token ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('by ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('token');
      await tester.pump(const Duration(milliseconds: 50));

      // Should show metrics
      expect(find.textContaining('tokens'), findsWidgets);

      controller.completeStreaming();
      await tester.pump();

      expect(controller.tokenCount, greaterThan(0));

      controller.dispose();
    });

    testWidgets('multiple streaming messages in conversation',
        (WidgetTester tester) async {
      final messages = <Widget>[];
      final controllers = <StreamingChatController>[];

      // Create 3 streaming controllers
      for (int i = 0; i < 3; i++) {
        final controller = StreamingChatController();
        controllers.add(controller);
        messages.add(
          StreamingMessageBubble(
            controller: controller,
            key: Key('streaming_$i'),
          ),
        );
      }

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: messages,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      for (var i = 0; i < controllers.length; i++) {
                        controllers[i].startStreaming();
                        controllers[i].addChunk('Message $i content');
                        Future.delayed(
                          Duration(milliseconds: 100 * (i + 1)),
                          () => controllers[i].completeStreaming(),
                        );
                      }
                    },
                    child: const Text('Start All'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start All'));
      await tester.pump();

      // Wait for all to complete
      await tester.pump(const Duration(milliseconds: 400));

      // All should be completed
      for (var controller in controllers) {
        expect(controller.state, StreamingState.completed);
      }

      // Dispose all
      for (var controller in controllers) {
        controller.dispose();
      }
    });

    testWidgets('streaming with markdown rendering',
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

      controller.startStreaming();
      controller.addChunk('**Bold** ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('and *italic* ');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('text');
      await tester.pump(const Duration(milliseconds: 50));

      controller.completeStreaming();
      await tester.pump();

      // Should render markdown
      expect(find.textContaining('Bold'), findsOneWidget);
      expect(find.textContaining('italic'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('streaming buffer management handles rapid chunks',
        (WidgetTester tester) async {
      final controller = StreamingChatController(
        bufferDelayMs: 10, // Fast buffering for test
      );

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

      controller.startStreaming();

      // Add many chunks rapidly
      for (int i = 0; i < 50; i++) {
        controller.addChunk('$i ');
      }

      await tester.pump(const Duration(milliseconds: 100));

      controller.completeStreaming();
      await tester.pump(const Duration(milliseconds: 100));

      // Should handle all chunks without errors
      expect(tester.takeException(), isNull);
      expect(controller.currentContent.contains('49'), isTrue);

      controller.dispose();
    });

    testWidgets('streaming with code blocks',
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

      controller.startStreaming();
      controller.addChunk('Here is some code:\n```dart\n');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('void main() {\n');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('  print("Hello");\n');
      await tester.pump(const Duration(milliseconds: 50));

      controller.addChunk('}\n```');
      await tester.pump(const Duration(milliseconds: 50));

      controller.completeStreaming();
      await tester.pump();

      // Should render code block
      expect(find.textContaining('dart'), findsWidgets);

      controller.dispose();
    });

    testWidgets('streaming completion transitions to regular message',
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

      controller.startStreaming();
      expect(controller.isStreaming, isTrue);

      controller.addChunk('Complete message');
      await tester.pump(const Duration(milliseconds: 50));

      controller.completeStreaming();
      await tester.pump();

      expect(controller.isStreaming, isFalse);
      expect(controller.isCompleted, isTrue);
      expect(find.text('Complete message'), findsOneWidget);

      controller.dispose();
    });
  });
}
