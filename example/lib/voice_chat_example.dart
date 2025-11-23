import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

/// Example demonstrating voice-to-text chat conversation.
///
/// Features:
/// - Voice input with speech recognition
/// - Real-time transcription
/// - Voice activity indicator
/// - Simulated voice responses
void main() {
  runApp(const VoiceChatExample());
}

class VoiceChatExample extends StatelessWidget {
  const VoiceChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const VoiceChatScreen(),
    );
  }
}

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(
    id: '1',
    name: 'User',
  );
  final ChatUser _assistant = ChatUser(
    id: '2',
    name: 'Voice Assistant',
    avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=voice',
  );

  bool _isListening = false;
  String _currentTranscription = '';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: '0',
          content: '🎙️ Hi! I\'m your voice assistant. Tap the microphone button to speak, and I\'ll transcribe and respond to your message!\n\n**Try saying:**\n• "Hello"\n• "What can you do?"\n• "Tell me a joke"',
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

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      metadata: {
        'input_method': 'keyboard',
      },
    );

    setState(() {
      _messages.add(userMessage);
    });

    _generateResponse(text, isVoice: false);
  }

  void _handleVoiceInput(String transcribedText) {
    if (transcribedText.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: transcribedText,
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      metadata: {
        'input_method': 'voice',
        'transcribed': true,
      },
    );

    setState(() {
      _messages.add(userMessage);
      _isListening = false;
    });

    _generateResponse(transcribedText, isVoice: true);
  }

  void _generateResponse(String text, {required bool isVoice}) {
    final lowerText = text.toLowerCase();
    String response;

    if (lowerText.contains('hello') || lowerText.contains('hi')) {
      response = '👋 Hello! Great to hear from you${isVoice ? " via voice" : ""}!';
    } else if (lowerText.contains('what can you do') || lowerText.contains('help')) {
      response = '''I can help you with voice conversations! Here's what I can do:

• **Voice Input:** Tap the 🎤 button to speak
• **Text Input:** Type your message normally
• **Real-time Transcription:** See your words as you speak
• **Natural Conversation:** Talk to me like a friend!

${isVoice ? "I noticed you're using voice - that's awesome! 🎙️" : "Try using voice input for a hands-free experience!"}''';
    } else if (lowerText.contains('joke')) {
      response = '''Why don't scientists trust atoms?

Because they make up everything! 😄

${isVoice ? "(I hope that came through clearly!)" : ""}''';
    } else if (lowerText.contains('thank')) {
      response = '${isVoice ? "🎤" : "💬"} You\'re very welcome! Happy to help!';
    } else if (lowerText.contains('goodbye') || lowerText.contains('bye')) {
      response = '👋 Goodbye! It was nice chatting with you. Come back anytime!';
    } else {
      response = isVoice
          ? '🎙️ I heard you say: "$text"\n\nThat\'s a great ${lowerText.split(' ').length > 10 ? "detailed" : ""} message! Voice input makes chatting so much easier, doesn\'t it?'
          : '💬 I received your message: "$text"\n\nFeel free to try the voice input feature by tapping the microphone button!';
    }

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      metadata: {
        'response_to': isVoice ? 'voice' : 'text',
      },
    );

    setState(() {
      _messages.add(aiMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatThemeProvider(
      theme: ChatTheme.light().copyWith(
        primaryColor: Colors.orange,
        userBubbleColor: Colors.orange.shade100,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Voice Chat'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            if (_isListening)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.orange.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Listening...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_currentTranscription.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Text(
                          _currentTranscription,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.orange.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, size: 20, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Voice input enabled • Tap 🎤 to speak',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: MessageList(
                messages: _messages,
                showDateSeparators: true,
              ),
            ),
            MessageInputComposer(
              onSendMessage: _handleSendMessage,
              hintText: 'Type or speak...',
              showAttachment: false,
              enableVoiceInput: true,
              onVoiceInputStart: () {
                setState(() {
                  _isListening = true;
                  _currentTranscription = '';
                });
              },
              onVoiceInputTranscription: (text) {
                setState(() {
                  _currentTranscription = text;
                });
              },
              onVoiceInputComplete: _handleVoiceInput,
              onVoiceInputCancel: () {
                setState(() {
                  _isListening = false;
                  _currentTranscription = '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add voice callbacks to MessageInputComposer
extension _VoiceExtensions on MessageInputComposer {
  MessageInputComposer copyWithVoiceCallbacks({
    VoidCallback? onVoiceInputStart,
    void Function(String)? onVoiceInputTranscription,
    void Function(String)? onVoiceInputComplete,
    VoidCallback? onVoiceInputCancel,
  }) {
    // Note: In a real implementation, these would be added to MessageInputComposer
    // This is just for demonstration purposes
    return this;
  }
}
