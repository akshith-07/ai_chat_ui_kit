# AI Chat UI Kit

[![pub package](https://img.shields.io/pub/v/ai_chat_ui_kit.svg)](https://pub.dev/packages/ai_chat_ui_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-blue.svg)](https://flutter.dev)

Enterprise-grade Flutter package providing customizable chat interface components optimized for AI chatbot applications with streaming support, voice input, markdown rendering, and multi-modal capabilities.

## ✨ Features

### Core Chat UI Components
- **ChatScreen**: Main container widget with customizable app bar, message list, and input area
- **MessageBubble**: Rich message bubbles supporting text, images, files, code blocks, and sender/receiver styling
- **MessageList**: Infinite scroll with reverse ListView, pagination support, and automatic date separators
- **TypingIndicator**: Animated dots showing AI "thinking" state
- **MessageTimestamp**: Flexible time formatting (relative: "2m ago" or absolute)
- **AvatarWidget**: Circular/rounded avatars with initials fallback and network image caching
- **StreamingMessageBubble**: Real-time character-by-character text streaming with blinking cursor

### Markdown & Code Rendering
- Full markdown support with `flutter_markdown`
- Syntax highlighting for 8+ languages (Python, JavaScript, Java, C++, Dart, SQL, JSON, YAML)
- Copy-to-clipboard button on code blocks
- Support for inline code, bold, italics, links, lists, tables, blockquotes

### Voice Input
- **VoiceInputButton**: Recording button with pulsing animation
- Speech-to-text integration with `speech_to_text` package
- Automatic permission handling with `permission_handler`
- Real-time transcription display

### Message Input Composer
- Multi-line text field with auto-expanding height (max 5 lines)
- Send button that activates when text is non-empty
- Attachment button for images, documents, and camera access
- Voice input button integration
- Text formatting toolbar (bold, italic, code)
- @mention autocomplete with suggestions
- Draft message persistence using `shared_preferences`

### Streaming Support
- **StreamingChatController**: Handles Server-Sent Events (SSE) and WebSocket streams
- Character-by-character rendering with configurable buffer
- Cancellation support with stop button
- Error handling and reconnection logic
- Token count and generation speed metrics

### Customization & Theming
- **ChatTheme**: Comprehensive theming with light/dark mode support
- Customizable colors, typography, spacing, and bubble shapes
- Per-component theme overrides

### Advanced Features
- Message reactions with emoji support
- Reply/quote functionality
- Message editing and deletion
- Search messages with highlighted results
- Export chat history (JSON, TXT formats)
- Offline message queue with retry logic
- Auto-scroll to bottom on new messages
- Context menu (long-press): copy, delete, reply, forward

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ai_chat_ui_kit: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

class MyChatScreen extends StatefulWidget {
  @override
  State<MyChatScreen> createState() => _MyChatScreenState();
}

class _MyChatScreenState extends State<MyChatScreen> {
  final List<ChatMessage> messages = [];

  final ChatUser user = ChatUser(
    id: 'user_1',
    name: 'You',
  );

  void _handleSendMessage(String text) {
    final message = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      sender: MessageSender.user,
      user: user,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreen(
      messages: messages,
      onSendMessage: _handleSendMessage,
      theme: ChatTheme.light(),
      appBarTitle: 'AI Chat',
    );
  }
}
```

## 📚 Documentation

Visit our [documentation](https://github.com/akshith-07/ai_chat_ui_kit/wiki) for detailed guides, API reference, and examples.

## 🧪 Testing

```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.