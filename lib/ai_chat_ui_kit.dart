/// AI Chat UI Kit - Enterprise-grade Flutter package for AI chatbot interfaces
///
/// Provides customizable chat interface components optimized for AI chatbot
/// applications with streaming support, voice input, markdown rendering,
/// and multi-modal capabilities.
///
/// ## Features
///
/// - **Rich Chat UI**: Message bubbles, avatars, timestamps, typing indicators
/// - **Streaming Support**: Real-time character-by-character message rendering
/// - **Markdown & Code**: Full markdown support with syntax highlighting
/// - **Voice Input**: Integrated speech-to-text with waveform visualization
/// - **Customizable Themes**: Light/dark modes with full customization
/// - **Advanced Features**: Reactions, replies, editing, search, and more
///
/// ## Quick Start
///
/// ```dart
/// import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';
///
/// ChatScreen(
///   messages: messages,
///   onSendMessage: (text) => sendMessage(text),
///   theme: ChatTheme.light(),
/// )
/// ```
library ai_chat_ui_kit;

// Core exports
export 'controllers/controllers.dart';
export 'models/models.dart';
export 'themes/themes.dart';
export 'utils/utils.dart';
export 'widgets/widgets.dart';
