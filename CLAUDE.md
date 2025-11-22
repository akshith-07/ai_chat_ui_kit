Create an enterprise-grade Flutter package called "ai_chat_ui_kit" that provides customizable chat interface components optimized for AI chatbot applications with the following specifications:

PACKAGE STRUCTURE:
- Follow Flutter package development best practices with feature-first architecture
- Use lib/ structure: core/, widgets/, models/, themes/, utils/, examples/
- Implement pubspec.yaml with semantic versioning (0.1.0)
- Include comprehensive README.md with badges, installation, quick start, and examples
- Add LICENSE (MIT), CHANGELOG.md, and example/ folder with working demo app
- Create analysis_options.yaml with strict linting rules

CORE FEATURES TO IMPLEMENT:

1. CHAT UI COMPONENTS:
   - ChatScreen: Main container widget with customizable app bar, message list, and input area
   - MessageBubble: Support text, image, file, code blocks with sender/receiver styling
   - MessageList: Infinite scroll with reverse ListView, pagination, date separators
   - TypingIndicator: Animated dots for AI "thinking" state
   - MessageTimestamp: Relative time (e.g., "2m ago") and absolute formats
   - AvatarWidget: Circular, rounded square with initials fallback and network image caching
   - StreamingMessageBubble: Shows text appearing character-by-character in real-time

2. MARKDOWN & CODE RENDERING:
   - Integrate flutter_markdown package for rich text rendering
   - Use flutter_highlighter or highlight package for syntax highlighting
   - Support languages: Python, JavaScript, Java, C++, Dart, SQL, JSON, YAML
   - Add copy-to-clipboard button on code blocks
   - Support inline code, bold, italics, links, lists, tables, blockquotes
   - Render LaTeX math equations using flutter_math_fork

3. VOICE INPUT:
   - Create VoiceInputButton widget with recording animation
   - Integrate speech_to_text package for voice recognition
   - Show waveform visualization during recording (use fl_chart)
   - Support pause/resume recording and audio preview
   - Add permission handling with permission_handler package
   - Return transcribed text to message input field

4. MESSAGE INPUT COMPOSER:
   - MultiLineTextField with auto-expanding height (max 5 lines)
   - Send button that activates when text is non-empty
   - Attachment button (image, document, camera access)
   - Voice input button integration
   - Text formatting toolbar (bold, italic, code)
   - @mention suggestions with autocomplete
   - Draft message persistence using shared_preferences

5. STREAMING SUPPORT:
   - StreamingChatController to handle Server-Sent Events (SSE) or WebSocket streams
   - Buffer management for character-by-character rendering
   - Cancellation support with stop button
   - Error handling and reconnection logic
   - Show token count and generation speed

6. CUSTOMIZATION & THEMING:
   - ChatTheme class with light/dark mode support
   - Customizable colors: primary, secondary, bubble colors, text colors
   - Typography settings: font families, sizes, weights
   - Border radius, padding, spacing configurations
   - Support for custom bubble shapes (rounded, sharp, tail variants)
   - BubbleShape enum: rounded, square, tailLeft, tailRight

7. RAG & MULTI-MODAL EXAMPLES:
   - Example 1: Basic chatbot with OpenAI API integration
   - Example 2: RAG chatbot showing document references with citation numbers
   - Example 3: Multi-modal chat with image analysis (vision API)
   - Example 4: Streaming chat with cancellation
   - Example 5: Voice-to-text conversation flow
   - Each example should be self-contained in example/ directory

MODELS & DATA STRUCTURES:
- ChatMessage: id, content, sender (user/assistant/system), timestamp, metadata, attachments
- MessageAttachment: type (image/file/audio), url, name, size
- ChatUser: id, name, avatar, isOnline
- StreamingState: streaming, completed, error, cancelled
- MessageStatus: sending, sent, delivered, read, failed

DEPENDENCIES TO INCLUDE:
dependencies:
flutter_markdown: ^0.7.0
flutter_highlighter: ^0.1.1
speech_to_text: ^7.0.0
permission_handler: ^11.0.0
cached_network_image: ^3.3.0
intl: ^0.19.0
url_launcher: ^6.2.0
shared_preferences: ^2.2.0
fl_chart: ^0.68.0
equatable: ^2.0.5

dev_dependencies:
flutter_test:
flutter_lints: ^4.0.0
mockito: ^5.4.0

text

TESTING REQUIREMENTS:
- Unit tests for models, controllers, utilities (80%+ coverage)
- Widget tests for all major UI components
- Integration tests for complete chat flows
- Mock API responses for example demonstrations
- Test both light and dark themes

DOCUMENTATION:
- Dartdoc comments for all public APIs
- README sections: Features, Installation, Quick Start, Customization, Examples, Contributing
- API reference documentation with code snippets
- Screenshots of each major component
- GIF demonstrations of streaming, voice input, and scrolling

ADVANCED FEATURES:
- Message reactions (emoji picker with flutter_emoji package)
- Reply/quote functionality
- Message editing and deletion
- Search messages with highlighted results
- Export chat history (JSON, TXT formats)
- Offline message queue with retry logic
- Auto-scroll to bottom on new messages
- Jump to unread separator
- Context menu (long-press): copy, delete, reply, forward

ACCESSIBILITY:
- Semantic labels for screen readers
- Sufficient color contrast (WCAG AA)
- Focus management for keyboard navigation
- Text scaling support (respect user font size settings)

PERFORMANCE OPTIMIZATIONS:
- Lazy loading with ListView.builder
- Image caching with cached_network_image
- Debounce text input for real-time features
- Dispose controllers properly to prevent memory leaks
- Optimize rebuild cycles with const constructors

PUBLISHING PREPARATION:
- Ensure package score 140/140 on pub.dev
- Add example screenshots to repository
- Create demo GIF for README
- Set up GitHub repository with issues/PR templates
- Add CI/CD with GitHub Actions for automated testing

OUTPUT:
Generate complete, production-ready code with:
1. Full package implementation
2. Working example app in example/ directory
3. Comprehensive test suite
4. Documentation for pub.dev
5. Follow Flutter and Dart best practices strictly
