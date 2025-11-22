import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import 'message_list.dart';
import 'message_input_composer.dart';

/// The main chat screen widget that combines all chat UI components.
///
/// Provides a complete chat interface with:
/// - Custom app bar
/// - Message list with pagination
/// - Input composer
/// - Theme support
///
/// Example:
/// ```dart
/// ChatScreen(
///   messages: chatMessages,
///   onSendMessage: (text) => sendMessage(text),
///   appBarTitle: 'AI Assistant',
///   theme: ChatTheme.light(),
/// )
/// ```
class ChatScreen extends StatelessWidget {
  /// Creates a chat screen.
  const ChatScreen({
    required this.messages,
    required this.onSendMessage,
    this.theme,
    this.appBarTitle = 'Chat',
    this.appBarActions = const <Widget>[],
    this.showAppBar = true,
    this.appBarLeading,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreMessages = false,
    this.showTypingIndicator = false,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onReactionTap,
    this.onAttachmentTap,
    this.onVoiceInput,
    this.inputHintText = 'Type a message...',
    this.showFormatting = true,
    this.showAttachment = true,
    this.showVoiceInput = true,
    this.enableMentions = false,
    this.mentionSuggestions = const <String>[],
    this.onMentionSearch,
    this.persistDrafts = true,
    this.draftKey = 'chat_draft',
    this.emptyWidget,
    this.backgroundColor,
    super.key,
  });

  /// List of messages to display
  final List<ChatMessage> messages;

  /// Callback when a message is sent
  final void Function(String text) onSendMessage;

  /// Optional theme override (will use default if not provided)
  final ChatTheme? theme;

  /// Title for the app bar
  final String appBarTitle;

  /// Actions for the app bar
  final List<Widget> appBarActions;

  /// Whether to show the app bar
  final bool showAppBar;

  /// Leading widget for the app bar
  final Widget? appBarLeading;

  /// Callback to load more messages
  final Future<void> Function()? onLoadMore;

  /// Whether messages are being loaded
  final bool isLoadingMore;

  /// Whether there are more messages to load
  final bool hasMoreMessages;

  /// Whether to show typing indicator
  final bool showTypingIndicator;

  /// Callback when a message is tapped
  final void Function(ChatMessage message)? onMessageTap;

  /// Callback when a message is long-pressed
  final void Function(ChatMessage message)? onMessageLongPress;

  /// Callback when a reaction is tapped
  final void Function(ChatMessage message, String emoji)? onReactionTap;

  /// Callback when attachment button is tapped
  final VoidCallback? onAttachmentTap;

  /// Callback when voice input is received
  final void Function(String text)? onVoiceInput;

  /// Placeholder text for input field
  final String inputHintText;

  /// Whether to show formatting toolbar
  final bool showFormatting;

  /// Whether to show attachment button
  final bool showAttachment;

  /// Whether to show voice input button
  final bool showVoiceInput;

  /// Whether to enable @mention autocomplete
  final bool enableMentions;

  /// List of mention suggestions
  final List<String> mentionSuggestions;

  /// Callback when searching for mentions
  final void Function(String query)? onMentionSearch;

  /// Whether to persist drafts
  final bool persistDrafts;

  /// Key for storing drafts
  final String draftKey;

  /// Widget to show when there are no messages
  final Widget? emptyWidget;

  /// Background color override
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ChatTheme effectiveTheme = theme ?? ChatTheme.light();

    return ChatThemeProvider(
      theme: effectiveTheme,
      child: Scaffold(
        backgroundColor: backgroundColor ?? effectiveTheme.backgroundColor,
        appBar: showAppBar
            ? AppBar(
                leading: appBarLeading,
                title: Text(appBarTitle),
                backgroundColor: effectiveTheme.primaryColor,
                foregroundColor: Colors.white,
                actions: appBarActions,
                elevation: 0,
              )
            : null,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: MessageList(
                  messages: messages,
                  onLoadMore: onLoadMore,
                  isLoadingMore: isLoadingMore,
                  hasMoreMessages: hasMoreMessages,
                  showTypingIndicator: showTypingIndicator,
                  onMessageTap: onMessageTap,
                  onMessageLongPress: onMessageLongPress,
                  onReactionTap: onReactionTap,
                  emptyWidget: emptyWidget,
                ),
              ),
              MessageInputComposer(
                onSendMessage: onSendMessage,
                onAttachmentTap: onAttachmentTap,
                onVoiceInput: onVoiceInput,
                hintText: inputHintText,
                showFormatting: showFormatting,
                showAttachment: showAttachment,
                showVoiceInput: showVoiceInput,
                enableMentions: enableMentions,
                mentionSuggestions: mentionSuggestions,
                onMentionSearch: onMentionSearch,
                persistDrafts: persistDrafts,
                draftKey: draftKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
