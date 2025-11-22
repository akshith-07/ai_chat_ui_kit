import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AI Chat UI Kit Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ChatExampleScreen(),
      );
}

class ChatExampleScreen extends StatefulWidget {
  const ChatExampleScreen({super.key});

  @override
  State<ChatExampleScreen> createState() => _ChatExampleScreenState();
}

class _ChatExampleScreenState extends State<ChatExampleScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final Uuid _uuid = const Uuid();
  bool _isTyping = false;

  final ChatUser _user = const ChatUser(
    id: 'user_1',
    name: 'You',
    avatar: null,
  );

  final ChatUser _assistant = const ChatUser(
    id: 'assistant_1',
    name: 'AI Assistant',
    avatar: null,
  );

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final ChatMessage welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      content: 'Hello! I\'m your AI assistant. How can I help you today?',
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  Future<void> _handleSendMessage(String text) async {
    final ChatMessage userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isTyping = true;
    });

    // Simulate AI response delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final ChatMessage assistantMessage = ChatMessage(
      id: _uuid.v4(),
      content: _generateResponse(text),
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, assistantMessage);
        _isTyping = false;
      });
    }
  }

  String _generateResponse(String userMessage) {
    // Simple mock responses
    if (userMessage.toLowerCase().contains('hello') ||
        userMessage.toLowerCase().contains('hi')) {
      return 'Hello! It\'s great to hear from you. How can I assist you today?';
    } else if (userMessage.toLowerCase().contains('help')) {
      return 'I\'m here to help! You can ask me questions, and I\'ll do my best to provide useful answers. Try asking me about:\n\n- Code examples\n- General information\n- Problem-solving\n\nWhat would you like to know?';
    } else if (userMessage.toLowerCase().contains('code')) {
      return 'Here\'s a simple Python example:\n\n```python\ndef greet(name):\n    return f"Hello, {name}!"\n\nprint(greet("World"))\n```\n\nThis function takes a name as input and returns a greeting message.';
    } else {
      return 'That\'s an interesting question! As a demo AI assistant, my responses are limited, but in a real application, I would process your message using advanced AI models to provide helpful and accurate answers.';
    }
  }

  @override
  Widget build(BuildContext context) => ChatScreen(
        messages: _messages,
        onSendMessage: _handleSendMessage,
        appBarTitle: 'AI Assistant',
        theme: ChatTheme.light(
          primaryColor: Colors.blue,
          userBubbleColor: Colors.blue,
        ),
        showTypingIndicator: _isTyping,
        showFormatting: true,
        showAttachment: true,
        showVoiceInput: true,
        appBarActions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
          ),
        ],
      );
}
