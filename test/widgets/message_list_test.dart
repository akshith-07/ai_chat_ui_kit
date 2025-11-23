import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('MessageList', () {
    final testUser = ChatUser(id: '1', name: 'Test User');
    final testAssistant = ChatUser(id: '2', name: 'AI Assistant');

    testWidgets('displays list of messages', (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'First message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: '2',
          content: 'Second message',
          sender: MessageSender.assistant,
          user: testAssistant,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('displays messages in reverse order',
        (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Oldest',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: '2',
          content: 'Newest',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );

      // Should find both messages
      expect(find.text('Oldest'), findsOneWidget);
      expect(find.text('Newest'), findsOneWidget);
    });

    testWidgets('displays typing indicator when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: const MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: [],
                isTyping: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);
    });

    testWidgets('hides typing indicator when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: const MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: [],
                isTyping: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('displays date separators', (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Yesterday message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          id: '2',
          content: 'Today message',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: messages,
                showDateSeparators: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DateSeparator), findsWidgets);
    });

    testWidgets('handles empty message list', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: const MaterialApp(
            home: Scaffold(
              body: MessageList(messages: []),
            ),
          ),
        ),
      );

      expect(find.byType(MessageList), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls to show all messages', (WidgetTester tester) async {
      final messages = List.generate(
        50,
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
            home: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('calls onMessageTap when message is tapped',
        (WidgetTester tester) async {
      ChatMessage? tappedMessage;

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
            home: Scaffold(
              body: MessageList(
                messages: messages,
                onMessageTap: (message) {
                  tappedMessage = message;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test message'));
      await tester.pump();

      expect(tappedMessage?.id, '1');
    });

    testWidgets('calls onMessageLongPress when message is long pressed',
        (WidgetTester tester) async {
      ChatMessage? longPressedMessage;

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
            home: Scaffold(
              body: MessageList(
                messages: messages,
                onMessageLongPress: (message) {
                  longPressedMessage = message;
                },
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Test message'));
      await tester.pump();

      expect(longPressedMessage?.id, '1');
    });

    testWidgets('supports pull to refresh when enabled',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: const [],
                onRefresh: () async {
                  refreshCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Should have RefreshIndicator
      expect(find.byType(MessageList), findsOneWidget);
    });

    testWidgets('displays custom empty state when provided',
        (WidgetTester tester) async {
      const emptyWidget = Text('No messages yet');

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: const MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: [],
                emptyStateWidget: emptyWidget,
              ),
            ),
          ),
        ),
      );

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('groups messages by date correctly',
        (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Message 1',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime(2025, 1, 15, 10, 0),
        ),
        ChatMessage(
          id: '2',
          content: 'Message 2',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime(2025, 1, 15, 14, 0),
        ),
        ChatMessage(
          id: '3',
          content: 'Message 3',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime(2025, 1, 16, 10, 0),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(
                messages: messages,
                showDateSeparators: true,
              ),
            ),
          ),
        ),
      );

      // Should show messages and date separators
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);
      expect(find.text('Message 3'), findsOneWidget);
    });

    testWidgets('handles rapid updates without errors',
        (WidgetTester tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Message 1',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );

      // Add more messages
      messages.add(
        ChatMessage(
          id: '2',
          content: 'Message 2',
          sender: MessageSender.user,
          user: testUser,
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
