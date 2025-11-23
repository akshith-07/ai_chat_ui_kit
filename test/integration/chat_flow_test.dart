import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('Complete Chat Flow Integration Tests', () {
    late List<ChatMessage> messages;
    late ChatUser user;
    late ChatUser assistant;

    setUp(() {
      messages = [];
      user = ChatUser(id: '1', name: 'Test User');
      assistant = ChatUser(id: '2', name: 'AI Assistant');
    });

    testWidgets('complete conversation flow from empty to multiple messages',
        (WidgetTester tester) async {
      bool isTyping = false;

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  isTyping: isTyping,
                  onSendMessage: (text) {
                    setState(() {
                      messages.add(
                        ChatMessage(
                          id: '${messages.length + 1}',
                          content: text,
                          sender: MessageSender.user,
                          user: user,
                          timestamp: DateTime.now(),
                          status: MessageStatus.sending,
                        ),
                      );

                      // Simulate AI typing
                      isTyping = true;
                    });

                    // Simulate AI response after delay
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        isTyping = false;
                        messages.add(
                          ChatMessage(
                            id: '${messages.length + 1}',
                            content: 'AI response to: $text',
                            sender: MessageSender.assistant,
                            user: assistant,
                            timestamp: DateTime.now(),
                            status: MessageStatus.sent,
                          ),
                        );
                      });
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Step 1: Verify initial empty state
      expect(find.byType(MessageBubble), findsNothing);
      expect(find.byType(TypingIndicator), findsNothing);

      // Step 2: Send first message
      await tester.enterText(find.byType(TextField), 'Hello AI');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Step 3: Verify user message appears
      expect(find.text('Hello AI'), findsOneWidget);
      expect(find.byType(TypingIndicator), findsOneWidget);

      // Step 4: Wait for AI response
      await tester.pump(const Duration(milliseconds: 150));

      // Step 5: Verify AI response appears and typing indicator disappears
      expect(find.text('AI response to: Hello AI'), findsOneWidget);
      expect(find.byType(TypingIndicator), findsNothing);

      // Step 6: Send second message
      await tester.enterText(find.byType(TextField), 'How are you?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Step 7: Verify second conversation
      expect(find.text('How are you?'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('AI response to: How are you?'), findsOneWidget);

      // Step 8: Verify total message count
      expect(messages.length, 4); // 2 user + 2 AI messages
    });

    testWidgets('message status updates from sending to sent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  showStatus: true,
                  onSendMessage: (text) {
                    setState(() {
                      messages.add(
                        ChatMessage(
                          id: '1',
                          content: text,
                          sender: MessageSender.user,
                          user: user,
                          timestamp: DateTime.now(),
                          status: MessageStatus.sending,
                        ),
                      );
                    });

                    // Simulate message sent
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        messages[0] = messages[0].copyWith(
                          status: MessageStatus.sent,
                        );
                      });
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Initially sending (clock icon)
      expect(find.byIcon(Icons.access_time), findsOneWidget);

      // After delay, sent (check icon)
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('date separators appear correctly as days change',
        (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      messages = [
        ChatMessage(
          id: '1',
          content: 'Yesterday message',
          sender: MessageSender.user,
          user: user,
          timestamp: yesterday,
        ),
        ChatMessage(
          id: '2',
          content: 'Today message',
          sender: MessageSender.user,
          user: user,
          timestamp: today,
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: ChatScreen(
              title: 'Test Chat',
              messages: messages,
              showDateSeparators: true,
              onSendMessage: (text) {},
            ),
          ),
        ),
      );

      // Should show both messages
      expect(find.text('Yesterday message'), findsOneWidget);
      expect(find.text('Today message'), findsOneWidget);

      // Should show date separators
      expect(find.byType(DateSeparator), findsWidgets);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('message reactions can be added and displayed',
        (WidgetTester tester) async {
      messages = [
        ChatMessage(
          id: '1',
          content: 'React to this message',
          sender: MessageSender.assistant,
          user: assistant,
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  onSendMessage: (text) {},
                  onReactionTap: (message, emoji) {
                    setState(() {
                      final reactions =
                          Map<String, List<String>>.from(message.reactions);
                      if (reactions.containsKey(emoji)) {
                        reactions[emoji]!.add(user.id);
                      } else {
                        reactions[emoji] = [user.id];
                      }
                      messages[0] = message.copyWith(reactions: reactions);
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('React to this message'), findsOneWidget);

      // Initially no reactions
      expect(find.text('👍'), findsNothing);

      // Simulate adding a reaction (this would normally be through a reaction picker)
      final messageBubble = tester.widget<MessageBubble>(
        find.byType(MessageBubble),
      );

      if (messageBubble.onReactionTap != null) {
        messageBubble.onReactionTap!(messages[0], '👍');
        await tester.pump();

        // Reaction should now appear
        expect(find.text('👍'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      }
    });

    testWidgets('message editing flow updates content',
        (WidgetTester tester) async {
      messages = [
        ChatMessage(
          id: '1',
          content: 'Original content',
          sender: MessageSender.user,
          user: user,
          timestamp: DateTime.now(),
          isEdited: false,
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  onSendMessage: (text) {},
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Original content'), findsOneWidget);
      expect(find.text('(edited)'), findsNothing);

      // Simulate editing
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                messages[0] = messages[0].copyWith(
                  content: 'Edited content',
                  isEdited: true,
                );

                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  onSendMessage: (text) {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edited content'), findsOneWidget);
      expect(find.text('(edited)'), findsOneWidget);
    });

    testWidgets('message deletion flow shows deletion placeholder',
        (WidgetTester tester) async {
      messages = [
        ChatMessage(
          id: '1',
          content: 'Message to delete',
          sender: MessageSender.user,
          user: user,
          timestamp: DateTime.now(),
          isDeleted: false,
        ),
      ];

      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  onSendMessage: (text) {},
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Message to delete'), findsOneWidget);
      expect(find.text('This message was deleted'), findsNothing);

      // Simulate deletion
      await tester.pumpWidget(
        ChatThemeProvider(
          theme: ChatTheme.light(),
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                messages[0] = messages[0].copyWith(isDeleted: true);

                return ChatScreen(
                  title: 'Test Chat',
                  messages: messages,
                  onSendMessage: (text) {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('This message was deleted'), findsOneWidget);
    });

    testWidgets('reply to message flow shows reply preview',
        (WidgetTester tester) async {
      final originalMessage = ChatMessage(
        id: '1',
        content: 'Original message to reply to',
        sender: MessageSender.assistant,
        user: assistant,
        timestamp: DateTime.now(),
      );

      messages = [
        originalMessage,
        ChatMessage(
          id: '2',
          content: 'This is a reply',
          sender: MessageSender.user,
          user: user,
          timestamp: DateTime.now(),
          replyTo: originalMessage,
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

      // Both messages should be visible
      expect(find.text('Original message to reply to'), findsWidgets);
      expect(find.text('This is a reply'), findsOneWidget);

      // Reply preview should show original content
      expect(find.textContaining('Original message'), findsWidgets);
    });

    testWidgets('long message list scrolls correctly',
        (WidgetTester tester) async {
      messages = List.generate(
        50,
        (i) => ChatMessage(
          id: '$i',
          content: 'Message number $i',
          sender: i.isEven ? MessageSender.user : MessageSender.assistant,
          user: i.isEven ? user : assistant,
          timestamp: DateTime.now().subtract(Duration(hours: 50 - i)),
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

      // Should render without errors
      expect(find.byType(ListView), findsOneWidget);

      // Scroll to top
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      // Should not throw errors
      expect(tester.takeException(), isNull);

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
