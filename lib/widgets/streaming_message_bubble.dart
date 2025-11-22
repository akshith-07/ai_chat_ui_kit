import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_user.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import '../controllers/streaming_chat_controller.dart';
import 'avatar_widget.dart';
import 'typing_indicator.dart';

/// A message bubble that displays streaming text in real-time.
///
/// Shows text appearing character-by-character with a blinking cursor
/// and optional token count/speed indicators.
///
/// Example:
/// ```dart
/// StreamingMessageBubble(
///   controller: streamingController,
///   user: assistantUser,
///   showMetrics: true,
/// )
/// ```
class StreamingMessageBubble extends StatefulWidget {
  /// Creates a streaming message bubble.
  const StreamingMessageBubble({
    required this.controller,
    required this.user,
    this.showAvatar = true,
    this.showCursor = true,
    this.showMetrics = false,
    this.onCancel,
    super.key,
  });

  /// The streaming controller managing the text
  final StreamingChatController controller;

  /// The user sending this message (typically the AI assistant)
  final ChatUser user;

  /// Whether to show the user avatar
  final bool showAvatar;

  /// Whether to show a blinking cursor while streaming
  final bool showCursor;

  /// Whether to show token count and speed metrics
  final bool showMetrics;

  /// Callback when user cancels streaming
  final VoidCallback? onCancel;

  @override
  State<StreamingMessageBubble> createState() => _StreamingMessageBubbleState();
}

class _StreamingMessageBubbleState extends State<StreamingMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatTheme theme = ChatThemeProvider.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.messageSpacing / 2,
        horizontal: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (widget.showAvatar && theme.showAvatars)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AvatarWidget(
                user: widget.user,
                size: theme.avatarSize,
              ),
            )
          else if (widget.showAvatar && theme.showAvatars)
            SizedBox(width: theme.avatarSize + 8.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildBubble(theme),
                if (widget.showMetrics && widget.controller.isStreaming)
                  _buildMetrics(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatTheme theme) {
    final bool isEmpty = widget.controller.streamedText.isEmpty;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        boxShadow: theme.elevateAssistantBubbles
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: theme.bubblePadding,
        child: isEmpty
            ? const TypingIndicator()
            : _buildStreamingContent(theme),
      ),
    );
  }

  Widget _buildStreamingContent(ChatTheme theme) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: MarkdownBody(
              data: widget.controller.streamedText,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: theme.assistantTextColor,
                  fontSize: theme.textFontSize,
                  fontWeight: theme.textFontWeight,
                  fontFamily: theme.textFontFamily,
                ),
                code: TextStyle(
                  backgroundColor:
                      theme.codeBackgroundColor.withOpacity(0.3),
                  color: theme.assistantTextColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          if (widget.showCursor && widget.controller.isStreaming)
            FadeTransition(
              opacity: _cursorController,
              child: Container(
                width: 2.0,
                height: theme.textFontSize * 1.2,
                margin: const EdgeInsets.only(left: 2.0),
                color: theme.assistantTextColor,
              ),
            ),
          if (widget.controller.isStreaming && widget.onCancel != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                onTap: widget.onCancel,
                child: Icon(
                  Icons.stop_circle,
                  size: 20.0,
                  color: theme.iconColor,
                ),
              ),
            ),
        ],
      );

  Widget _buildMetrics(ChatTheme theme) => Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
        child: Text(
          '${widget.controller.tokenCount} tokens • '
          '${widget.controller.tokensPerSecond.toStringAsFixed(1)} tok/s',
          style: TextStyle(
            fontSize: 11.0,
            color: theme.timestampColor,
          ),
        ),
      );
}
