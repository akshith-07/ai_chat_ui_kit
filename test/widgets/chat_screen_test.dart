import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('ChatScreen', () {
    final testUser = ChatUser(id: '1', name: 'Test User');

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Chat'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays message list', (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Test message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageList), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays message input composer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageInputComposer), findsOneWidget);
    });

    testWidgets('calls onSendMessage when message is sent',
        (WidgetTester tester) async {
      String? sentMessage;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {
                sentMessage = text;
              },
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

    testWidgets('shows typing indicator when isTyping is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              isTyping: true,
            ),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);
    });

    testWidgets('hides typing indicator when isTyping is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              isTyping: false,
            ),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('displays custom app bar actions when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('uses custom app bar widget when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              messages: const [],
              onSendMessage: (text) {},
              appBar: AppBar(
                title: const Text('Custom App Bar'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom App Bar'), findsOneWidget);
    });

    testWidgets('supports voice input when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              enableVoiceInput: true,
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('hides voice input when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              enableVoiceInput: false,
            ),
          ),
        ),
      );

      expect(find.byType(VoiceInputButton), findsNothing);
    });

    testWidgets('applies ChatTheme styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.dark(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('handles empty message list', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles large message lists', (WidgetTester tester) async {
      final messages = List.generate(
        100,
        (i) => ChatMessage(
          id: '$i',
          content: 'Message $i',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(MessageList), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses custom input hint when provided',
        (WidgetTester tester) async {
      const customHint = 'Type your custom message...';

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
              inputHint: customHint,
            ),
          ),
        ),
      );

      expect(find.text(customHint), findsOneWidget);
    });

    testWidgets('calls onMessageTap when message is tapped',
        (WidgetTester tester) async {
      ChatMessage? tappedMessage;

      final messages = [
        ChatMessage(
          id: '1',
          content: 'Tappable message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              onSendMessage: (text) {},
              onMessageTap: (message) {
                tappedMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable message'));
      await tester.pump();

      expect(tappedMessage?.id, '1');
    });

    testWidgets('calls onMessageLongPress when message is long pressed',
        (WidgetTester tester) async {
      ChatMessage? longPressedMessage;

      final messages = [
        ChatMessage(
          id: '1',
          content: 'Long pressable message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              onSendMessage: (text) {},
              onMessageLongPress: (message) {
                longPressedMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long pressable message'));
      await tester.pump();

      expect(longPressedMessage?.id, '1');
    });

    testWidgets('shows date separators when enabled',
        (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Message 1',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          id: '2',
          content: 'Message 2',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              onSendMessage: (text) {},
              showDateSeparators: true,
            ),
          ),
        ),
      );

      expect(find.byType(DateSeparator), findsWidgets);
    });

    testWidgets('properly disposes resources', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: const [],
              onSendMessage: (text) {},
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
  });
}
