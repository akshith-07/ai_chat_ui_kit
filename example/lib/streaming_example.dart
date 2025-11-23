import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

/// Example demonstrating streaming chat with real-time text generation.
///
/// Features:
/// - Character-by-character streaming
/// - Cancellation support
/// - Token metrics display
/// - Simulated AI responses
void main() {
  runApp(const StreamingChatExample());
}

class StreamingChatExample extends StatelessWidget {
  const StreamingChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streaming Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StreamingChatScreen(),
    );
  }
}

class StreamingChatScreen extends StatefulWidget {
  const StreamingChatScreen({super.key});

  @override
  State<StreamingChatScreen> createState() => _StreamingChatScreenState();
}

class _StreamingChatScreenState extends State<StreamingChatScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(
    id: '1',
    name: 'User',
    avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=user',
  );
  final ChatUser _assistant = ChatUser(
    id: '2',
    name: 'AI Assistant',
    avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=assistant',
  );

  StreamingChatController? _streamingController;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _streamingController?.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: '0',
          content: 'Hello! I\'m a streaming AI assistant. Try asking me something, and watch the response stream in real-time!',
          sender: MessageSender.assistant,
          user: _assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      );
    });
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(userMessage);
      _isStreaming = true;
    });

    // Simulate streaming response
    _simulateStreamingResponse(text);
  }

  Future<void> _simulateStreamingResponse(String userMessage) async {
    // Create new streaming controller
    _streamingController?.dispose();
    _streamingController = StreamingChatController(bufferDelayMs: 30);

    // Add streaming message placeholder
    final streamingMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '', // Will be filled by streaming
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(streamingMessage);
    });

    // Start streaming
    _streamingController!.startStreaming();

    // Simulate AI response generation
    final responses = _generateResponseChunks(userMessage);

    for (final chunk in responses) {
      if (_streamingController!.state == StreamingState.cancelled) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 50));
      _streamingController!.addChunk(chunk);
    }

    // Complete streaming
    if (_streamingController!.state == StreamingState.streaming) {
      _streamingController!.completeStreaming();

      // Update the message with final content
      setState(() {
        final index = _messages.indexOf(streamingMessage);
        _messages[index] = streamingMessage.copyWith(
          content: _streamingController!.currentContent,
        );
        _isStreaming = false;
      });
    } else {
      setState(() {
        _isStreaming = false;
      });
    }
  }

  List<String> _generateResponseChunks(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('code') || lowerMessage.contains('program')) {
      return [
        'Sure! Here\'s a ',
        'simple example:\n\n',
        '```dart\n',
        'void main() {\n',
        '  print("Hello from streaming AI!");\n',
        '  \n',
        '  // This response is streamed\n',
        '  // character by character\n',
        '}\n',
        '```\n\n',
        'This demonstrates how code blocks ',
        'can be streamed in real-time!'
      ];
    } else if (lowerMessage.contains('how') || lowerMessage.contains('what')) {
      return [
        'That\'s a great question! ',
        'Let me explain it to you.\n\n',
        'Streaming chat works by ',
        'sending the response in small chunks ',
        'as it\'s being generated, ',
        'rather than waiting for ',
        'the entire response to complete.\n\n',
        '**Benefits:**\n',
        '- Better user experience\n',
        '- Appears faster\n',
        '- Can be cancelled mid-stream\n\n',
        'Pretty cool, right?'
      ];
    } else {
      return [
        'I received your message: ',
        '"${userMessage.length > 50 ? userMessage.substring(0, 50) + '...' : userMessage}"\n\n',
        'I\'m a demo streaming assistant. ',
        'Watch as my response appears ',
        'word by word! ',
        'You can cancel the stream at any time ',
        'using the stop button.\n\n',
        'Try asking me about **code** or **how streaming works** ',
        'for different responses!'
      ];
    }
  }

  void _cancelStreaming() {
    if (_streamingController != null && _isStreaming) {
      _streamingController!.cancel();
      setState(() {
        _isStreaming = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Streaming cancelled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatThemeProvider(
      theme: ChatTheme.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Streaming Chat'),
          actions: [
            if (_isStreaming)
              IconButton(
                icon: const Icon(Icons.stop_circle),
                tooltip: 'Cancel streaming',
                onPressed: _cancelStreaming,
              ),
          ],
        ),
        body: Column(
          children: [
            if (_isStreaming)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.blue.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('AI is responding...'),
                  ],
                ),
              ),
            Expanded(
              child: MessageList(
                messages: _messages,
                showDateSeparators: true,
                customMessageBuilder: (message, index) {
                  // Use streaming bubble for the last message if streaming
                  if (_isStreaming &&
                      index == _messages.length - 1 &&
                      message.isAssistant &&
                      _streamingController != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: StreamingMessageBubble(
                        controller: _streamingController!,
                        showMetrics: true,
                      ),
                    );
                  }
                  return null; // Use default MessageBubble
                },
              ),
            ),
            MessageInputComposer(
              onSendMessage: _handleSendMessage,
              hintText: 'Ask me anything...',
              showAttachment: false,
              enableVoiceInput: false,
            ),
          ],
        ),
      ),
    );
  }
}
