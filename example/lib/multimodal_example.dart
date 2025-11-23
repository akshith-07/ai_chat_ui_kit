import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

/// Example demonstrating multi-modal chat with image analysis.
///
/// Features:
/// - Image attachments
/// - Simulated vision AI responses
/// - Multiple attachment types
/// - Rich media previews
void main() {
  runApp(const MultiModalChatExample());
}

class MultiModalChatExample extends StatelessWidget {
  const MultiModalChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Modal Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const MultiModalChatScreen(),
    );
  }
}

class MultiModalChatScreen extends StatefulWidget {
  const MultiModalChatScreen({super.key});

  @override
  State<MultiModalChatScreen> createState() => _MultiModalChatScreenState();
}

class _MultiModalChatScreenState extends State<MultiModalChatScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(
    id: '1',
    name: 'User',
  );
  final ChatUser _assistant = ChatUser(
    id: '2',
    name: 'Vision AI',
    avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=vision',
  );

  // Sample images for demo
  final List<SampleImage> _sampleImages = [
    SampleImage(
      url: 'https://picsum.photos/400/300?random=1',
      description: 'A beautiful landscape with mountains and a lake',
      tags: ['nature', 'landscape', 'mountains', 'water'],
    ),
    SampleImage(
      url: 'https://picsum.photos/400/300?random=2',
      description: 'Urban architecture with modern buildings',
      tags: ['city', 'buildings', 'architecture', 'urban'],
    ),
    SampleImage(
      url: 'https://picsum.photos/400/300?random=3',
      description: 'A close-up of colorful flowers',
      tags: ['flowers', 'nature', 'colorful', 'close-up'],
    ),
  ];

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
          content: '👁️ Hello! I\'m a multi-modal AI assistant with vision capabilities. Send me an image and I\'ll analyze it for you!\n\nTap the attachment button 📎 to select a sample image.',
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
    );

    setState(() {
      _messages.add(userMessage);
    });

    // Generate text response
    _generateTextResponse(text);
  }

  void _handleAttachmentTap() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a sample image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                itemBuilder: (context, index) {
                  final image = _sampleImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _sendImageMessage(image);
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image.url,
                              height: 120,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sample ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            image.description,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendImageMessage(SampleImage image) {
    // Create message with image attachment
    final attachment = MessageAttachment(
      type: AttachmentType.image,
      url: image.url,
      name: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      size: 1024 * 250, // 250 KB
      thumbnailUrl: image.url,
    );

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'What do you see in this image?',
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      attachments: [attachment],
    );

    setState(() {
      _messages.add(userMessage);
    });

    // Simulate vision AI analysis
    Future.delayed(const Duration(seconds: 1), () {
      _generateVisionResponse(image);
    });
  }

  void _generateVisionResponse(SampleImage image) {
    final buffer = StringBuffer();

    buffer.writeln('🔍 **Image Analysis:**\n');
    buffer.writeln(image.description);
    buffer.writeln('\n**Detected Elements:**');

    for (final tag in image.tags) {
      buffer.writeln('• ${tag[0].toUpperCase()}${tag.substring(1)}');
    }

    buffer.writeln('\n**Confidence:** ${(85 + Random().nextInt(15))}%');
    buffer.writeln('\n**Details:**');
    buffer.writeln('• Resolution: 400x300 pixels');
    buffer.writeln('• Format: JPEG');
    buffer.writeln('• Color Space: RGB');

    buffer.writeln('\n*This is a simulated vision AI response. In a real application, this would use an actual vision API like GPT-4 Vision, Google Cloud Vision, or Azure Computer Vision.*');

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: buffer.toString(),
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      metadata: {
        'model': 'vision-ai-demo',
        'analysis_time': '1.2s',
        'tags': image.tags,
      },
    );

    setState(() {
      _messages.add(aiMessage);
    });
  }

  void _generateTextResponse(String text) {
    final lowerText = text.toLowerCase();
    String response;

    if (lowerText.contains('image') || lowerText.contains('picture')) {
      response = 'To analyze an image, tap the 📎 attachment button below and select a sample image. I\'ll analyze it and describe what I see!';
    } else if (lowerText.contains('hello') || lowerText.contains('hi')) {
      response = 'Hello! I\'m ready to analyze images. Send me one to get started! 📸';
    } else if (lowerText.contains('help')) {
      response = '''**How to use multi-modal chat:**

1. Tap the 📎 button to select an image
2. Choose from the sample images
3. I'll analyze and describe what I see

**What I can detect:**
• Objects and scenes
• Colors and composition
• Text in images
• Faces and emotions
• And much more!''';
    } else {
      response = 'I received your message: "$text". To see my vision capabilities in action, try sending me an image! 🖼️';
    }

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      sender: MessageSender.assistant,
      user: _assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(aiMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatThemeProvider(
      theme: ChatTheme.light().copyWith(
        primaryColor: Colors.teal,
        userBubbleColor: Colors.teal.shade100,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Multi-Modal Chat'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.teal.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Vision AI • Supports images, documents, and more',
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
              onAttachmentTap: _handleAttachmentTap,
              hintText: 'Send an image or ask a question...',
              showAttachment: true,
              enableVoiceInput: false,
            ),
          ],
        ),
      ),
    );
  }
}

class SampleImage {
  final String url;
  final String description;
  final List<String> tags;

  SampleImage({
    required this.url,
    required this.description,
    required this.tags,
  });
}
