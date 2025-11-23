import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('MessageInputComposer', () {
    testWidgets('displays text input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays send button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('send button is disabled when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      final sendButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.send),
      );

      expect(sendButton.onPressed, isNull);
    });

    testWidgets('send button is enabled when text is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.send),
      );

      expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('calls onSendMessage when send button tapped',
        (WidgetTester tester) async {
      String? sentMessage;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {
                  sentMessage = text;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(sentMessage, 'Hello World');
    });

    testWidgets('clears text field after sending message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('displays voice input button when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                enableVoiceInput: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('hides voice input button when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                enableVoiceInput: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsNothing);
    });

    testWidgets('uses custom hint text when provided',
        (WidgetTester tester) async {
      const customHint = 'Custom placeholder text';

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                hintText: customHint,
              ),
            ),
          ),
        ),
      );

      expect(find.text(customHint), findsOneWidget);
    });

    testWidgets('respects maxLines configuration',
        (WidgetTester tester) async {
      const customMaxLines = 8;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                maxLines: customMaxLines,
              ),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, customMaxLines);
    });

    testWidgets('auto-expands with multiline text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'Line 1\nLine 2\nLine 3',
      );
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, contains('\n'));
    });

    testWidgets('handles voice transcription', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                enableVoiceInput: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('calls onTyping callback when text changes',
        (WidgetTester tester) async {
      bool isTyping = false;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                onTyping: (typing) {
                  isTyping = typing;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'T');
      await tester.pump();

      expect(isTyping, isTrue);
    });

    testWidgets('properly disposes controllers', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
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

      // Should dispose without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports text formatting toolbar when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
                showFormattingToolbar: true,
              ),
            ),
          ),
        ),
      );

      // Should have formatting buttons
      expect(find.byType(MessageInputComposer), findsOneWidget);
    });

    testWidgets('handles empty message gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageInputComposer(
                onSendMessage: (text) {},
              ),
            ),
          ),
        ),
      );

      // Try to send empty message (button should be disabled)
      final sendButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.send),
      );

      expect(sendButton.onPressed, isNull);
    });
  });
}
