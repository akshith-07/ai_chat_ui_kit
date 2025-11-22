import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import '../utils/time_formatter.dart';
import 'message_bubble.dart';
import 'date_separator.dart';
import 'typing_indicator.dart';

/// A scrollable list of chat messages with pagination and date separators.
///
/// Displays messages in reverse order (newest at bottom) with automatic
/// scrolling, date separators, and pull-to-refresh for loading more messages.
///
/// Example:
/// ```dart
/// MessageList(
///   messages: chatMessages,
///   onLoadMore: () async => await loadMoreMessages(),
///   showTypingIndicator: isAiTyping,
/// )
/// ```
class MessageList extends StatefulWidget {
  /// Creates a message list widget.
  const MessageList({
    required this.messages,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreMessages = false,
    this.showTypingIndicator = false,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onReactionTap,
    this.scrollToBottomOnNewMessage = true,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.scrollController,
    super.key,
  });

  /// List of messages to display
  final List<ChatMessage> messages;

  /// Callback to load more messages (for pagination)
  final Future<void> Function()? onLoadMore;

  /// Whether messages are currently being loaded
  final bool isLoadingMore;

  /// Whether there are more messages to load
  final bool hasMoreMessages;

  /// Whether to show the typing indicator
  final bool showTypingIndicator;

  /// Callback when a message is tapped
  final void Function(ChatMessage message)? onMessageTap;

  /// Callback when a message is long-pressed
  final void Function(ChatMessage message)? onMessageLongPress;

  /// Callback when a reaction is tapped
  final void Function(ChatMessage message, String emoji)? onReactionTap;

  /// Whether to auto-scroll to bottom when new messages arrive
  final bool scrollToBottomOnNewMessage;

  /// Widget to show when there are no messages
  final Widget? emptyWidget;

  /// Widget to show while loading
  final Widget? loadingWidget;

  /// Widget to show on error
  final Widget? errorWidget;

  /// Optional external scroll controller
  final ScrollController? scrollController;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late ScrollController _scrollController;
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new messages arrive
    if (widget.scrollToBottomOnNewMessage &&
        widget.messages.length > oldWidget.messages.length &&
        _isNearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _onScroll() {
    // Check if near bottom (within 100 pixels)
    final bool nearBottom =
        _scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 100;

    if (nearBottom != _isNearBottom) {
      setState(() {
        _isNearBottom = nearBottom;
      });
    }

    // Load more messages when near the top
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !widget.isLoadingMore &&
        widget.hasMoreMessages) {
      widget.onLoadMore?.call();
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatTheme theme = ChatThemeProvider.of(context);

    if (widget.messages.isEmpty && !widget.showTypingIndicator) {
      return widget.emptyWidget ?? _buildEmptyState(theme);
    }

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _getItemCount(),
          itemBuilder: (BuildContext context, int index) =>
              _buildItem(context, index, theme),
        ),
        if (!_isNearBottom) _buildScrollToBottomButton(theme),
      ],
    );
  }

  int _getItemCount() {
    int count = widget.messages.length;

    // Add date separators
    for (int i = 0; i < widget.messages.length - 1; i++) {
      if (TimeFormatter.isDifferentDay(
        widget.messages[i].timestamp,
        widget.messages[i + 1].timestamp,
      )) {
        count++;
      }
    }

    // Add typing indicator
    if (widget.showTypingIndicator) count++;

    // Add loading indicator
    if (widget.isLoadingMore) count++;

    return count;
  }

  Widget _buildItem(BuildContext context, int index, ChatTheme theme) {
    // Show loading indicator at the top
    if (widget.isLoadingMore && index == _getItemCount() - 1) {
      return _buildLoadingIndicator(theme);
    }

    // Show typing indicator at the bottom
    if (widget.showTypingIndicator && index == 0) {
      return _buildTypingIndicatorRow(theme);
    }

    // Adjust index for typing indicator
    int messageIndex = index;
    if (widget.showTypingIndicator) messageIndex--;

    // Check if we need a date separator
    if (messageIndex < widget.messages.length - 1) {
      final ChatMessage currentMessage = widget.messages[messageIndex];
      final ChatMessage nextMessage = widget.messages[messageIndex + 1];

      if (TimeFormatter.isDifferentDay(
        currentMessage.timestamp,
        nextMessage.timestamp,
      )) {
        return Column(
          children: <Widget>[
            MessageBubble(
              message: currentMessage,
              onTap: () => widget.onMessageTap?.call(currentMessage),
              onLongPress: () => widget.onMessageLongPress?.call(currentMessage),
              onReactionTap: (String emoji) =>
                  widget.onReactionTap?.call(currentMessage, emoji),
            ),
            DateSeparator(
              date: nextMessage.timestamp,
              textColor: theme.timestampColor,
              backgroundColor: theme.backgroundColor,
            ),
          ],
        );
      }
    }

    final ChatMessage message = widget.messages[messageIndex];
    return MessageBubble(
      message: message,
      onTap: () => widget.onMessageTap?.call(message),
      onLongPress: () => widget.onMessageLongPress?.call(message),
      onReactionTap: (String emoji) => widget.onReactionTap?.call(message, emoji),
    );
  }

  Widget _buildEmptyState(ChatTheme theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.chat_bubble_outline,
              size: 64.0,
              color: theme.iconColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18.0,
                color: theme.timestampColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Start a conversation!',
              style: TextStyle(
                fontSize: 14.0,
                color: theme.timestampColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildLoadingIndicator(ChatTheme theme) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );

  Widget _buildTypingIndicatorRow(ChatTheme theme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: theme.assistantBubbleColor,
                borderRadius: BorderRadius.circular(theme.borderRadius),
              ),
              child: const TypingIndicator(),
            ),
          ],
        ),
      );

  Widget _buildScrollToBottomButton(ChatTheme theme) => Positioned(
        right: 16.0,
        bottom: 16.0,
        child: FloatingActionButton(
          mini: true,
          backgroundColor: theme.primaryColor,
          onPressed: _scrollToBottom,
          child: const Icon(Icons.arrow_downward, color: Colors.white),
        ),
      );
}
