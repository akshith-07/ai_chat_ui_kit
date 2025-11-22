## 0.1.0

### Initial Release

**Core Features:**
- ✅ Chat UI components (ChatScreen, MessageBubble, MessageList, TypingIndicator)
- ✅ Streaming message support with character-by-character rendering
- ✅ Markdown rendering with syntax highlighting for multiple languages
- ✅ Voice input with waveform visualization
- ✅ Message input composer with formatting toolbar
- ✅ Customizable theming system (light/dark modes)
- ✅ Avatar widget with fallback support
- ✅ Message timestamps (relative and absolute formats)

**Advanced Features:**
- ✅ Message reactions with emoji picker
- ✅ Reply/quote functionality
- ✅ Message editing and deletion
- ✅ Search messages with highlighting
- ✅ Export chat history (JSON, TXT)
- ✅ Offline message queue with retry logic
- ✅ Context menu (copy, delete, reply, forward)
- ✅ Auto-scroll to bottom on new messages
- ✅ Jump to unread separator

**Data Models:**
- ✅ ChatMessage with metadata and attachments
- ✅ ChatUser with online status
- ✅ MessageAttachment for images, files, and audio
- ✅ StreamingState and MessageStatus enums

**Examples:**
- ✅ Basic chatbot with OpenAI API integration
- ✅ RAG chatbot with document references
- ✅ Multi-modal chat with image analysis
- ✅ Streaming chat with cancellation
- ✅ Voice-to-text conversation flow

**Testing:**
- ✅ Comprehensive unit tests for models and controllers
- ✅ Widget tests for all UI components
- ✅ Integration tests for complete chat flows
- ✅ Mock API responses for demonstrations

**Documentation:**
- ✅ Complete API documentation with dartdoc
- ✅ Comprehensive README with examples
- ✅ Code snippets and usage guides
- ✅ Accessibility guidelines

**Accessibility:**
- ✅ Semantic labels for screen readers
- ✅ WCAG AA color contrast compliance
- ✅ Keyboard navigation support
- ✅ Text scaling support

**Performance:**
- ✅ Lazy loading with ListView.builder
- ✅ Image caching optimization
- ✅ Debounced text input
- ✅ Proper controller disposal
- ✅ Optimized rebuild cycles
