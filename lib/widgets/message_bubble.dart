import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_message.dart';
import '../models/message_sender.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import '../themes/bubble_shape.dart';
import 'avatar_widget.dart';
import 'message_timestamp.dart';
import 'code_block_widget.dart';

/// A customizable message bubble widget.
///
/// Displays messages with support for text, markdown, code blocks,
/// attachments, reactions, and more.
///
/// Example:
/// ```dart
/// MessageBubble(
///   message: chatMessage,
///   showAvatar: true,
///   showTimestamp: true,
/// )
/// ```
class MessageBubble extends StatelessWidget {
  /// Creates a message bubble.
  const MessageBubble({
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.showUserName = false,
    this.onTap,
    this.onLongPress,
    this.onReactionTap,
    super.key,
  });

  /// The message to display
  final ChatMessage message;

  /// Whether to show the user avatar
  final bool showAvatar;

  /// Whether to show the message timestamp
  final bool showTimestamp;

  /// Whether to show the user name above the bubble
  final bool showUserName;

  /// Callback when the bubble is tapped
  final VoidCallback? onTap;

  /// Callback when the bubble is long-pressed
  final VoidCallback? onLongPress;

  /// Callback when a reaction is tapped
  final void Function(String emoji)? onReactionTap;

  bool get _isUser => message.sender == MessageSender.user;
  bool get _isSystem => message.sender == MessageSender.system;

  @override
  Widget build(BuildContext context) {
    final ChatTheme theme = ChatThemeProvider.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.messageSpacing / 2,
        horizontal: 8.0,
      ),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!_isUser && showAvatar && theme.showAvatars)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AvatarWidget(
                user: message.user,
                size: theme.avatarSize,
              ),
            )
          else if (!_isUser && showAvatar && theme.showAvatars)
            SizedBox(width: theme.avatarSize + 8.0),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  _isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: <Widget>[
                if (showUserName && theme.showUserNames)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 4.0,
                    ),
                    child: Text(
                      message.user.name,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.timestampColor,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: _buildBubble(theme),
                ),
                if (showTimestamp && theme.showTimestamps)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      top: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MessageTimestamp(
                          timestamp: message.timestamp,
                          color: theme.timestampColor,
                          fontSize: theme.timestampFontSize,
                        ),
                        if (message.isEdited) ...<Widget>[
                          const SizedBox(width: 4.0),
                          Text(
                            '(edited)',
                            style: TextStyle(
                              fontSize: theme.timestampFontSize,
                              color: theme.timestampColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (message.hasReactions) _buildReactions(theme),
              ],
            ),
          ),
          if (_isUser && showAvatar && theme.showAvatars)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AvatarWidget(
                user: message.user,
                size: theme.avatarSize,
              ),
            )
          else if (_isUser && showAvatar && theme.showAvatars)
            SizedBox(width: theme.avatarSize + 8.0),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatTheme theme) {
    final Color bubbleColor =
        _isUser
            ? theme.userBubbleColor
            : (_isSystem ? theme.systemBubbleColor : theme.assistantBubbleColor);

    final Color textColor =
        _isUser
            ? theme.userTextColor
            : (_isSystem ? theme.systemTextColor : theme.assistantTextColor);

    final bool elevate =
        _isUser ? theme.elevateUserBubbles : theme.elevateAssistantBubbles;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context as BuildContext).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: _getBorderRadius(theme),
        boxShadow: elevate
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (message.isReply && message.replyTo != null)
            _buildReplyPreview(theme),
          if (message.isDeleted)
            _buildDeletedMessage(theme, textColor)
          else
            _buildMessageContent(theme, textColor),
          if (message.hasAttachments) _buildAttachments(theme),
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius(ChatTheme theme) {
    switch (theme.bubbleShape) {
      case BubbleShape.rounded:
        return BorderRadius.circular(theme.borderRadius);
      case BubbleShape.square:
        return BorderRadius.zero;
      case BubbleShape.tailLeft:
        return BorderRadius.only(
          topLeft: Radius.circular(theme.borderRadius),
          topRight: Radius.circular(theme.borderRadius),
          bottomRight: Radius.circular(theme.borderRadius),
          bottomLeft: const Radius.circular(4.0),
        );
      case BubbleShape.tailRight:
        return BorderRadius.only(
          topLeft: Radius.circular(theme.borderRadius),
          topRight: Radius.circular(theme.borderRadius),
          bottomLeft: Radius.circular(theme.borderRadius),
          bottomRight: const Radius.circular(4.0),
        );
    }
  }

  Widget _buildMessageContent(ChatTheme theme, Color textColor) {
    // Check if message contains code blocks
    if (message.content.contains('```')) {
      return Padding(
        padding: theme.bubblePadding,
        child: MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: textColor,
              fontSize: theme.textFontSize,
              fontWeight: theme.textFontWeight,
              fontFamily: theme.textFontFamily,
            ),
            code: TextStyle(
              backgroundColor: theme.codeBackgroundColor,
              color: theme.codeTextColor,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: theme.codeBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onTapLink: (String text, String? href, String title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
        ),
      );
    }

    return Padding(
      padding: theme.bubblePadding,
      child: MarkdownBody(
        data: message.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: textColor,
            fontSize: theme.textFontSize,
            fontWeight: theme.textFontWeight,
            fontFamily: theme.textFontFamily,
          ),
          a: TextStyle(
            color: theme.linkColor,
            decoration: TextDecoration.underline,
          ),
          code: TextStyle(
            backgroundColor: theme.codeBackgroundColor.withOpacity(0.3),
            color: textColor,
            fontFamily: 'monospace',
          ),
          strong: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          em: TextStyle(
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
        ),
        onTapLink: (String text, String? href, String title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
      ),
    );
  }

  Widget _buildDeletedMessage(ChatTheme theme, Color textColor) => Padding(
        padding: theme.bubblePadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.block,
              size: 16.0,
              color: textColor.withOpacity(0.6),
            ),
            const SizedBox(width: 8.0),
            Text(
              'This message was deleted',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: theme.textFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );

  Widget _buildReplyPreview(ChatTheme theme) => Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border(
            left: BorderSide(
              color: theme.primaryColor,
              width: 3.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.replyTo!.user.name,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              message.replyTo!.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
                color: _isUser ? theme.userTextColor : theme.assistantTextColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildAttachments(ChatTheme theme) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: message.attachments
              .map((attachment) => _buildAttachment(attachment, theme))
              .toList(),
        ),
      );

  Widget _buildAttachment(dynamic attachment, ChatTheme theme) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.attach_file, size: 16.0),
            const SizedBox(width: 4.0),
            Text(
              attachment.name as String,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      );

  Widget _buildReactions(ChatTheme theme) => Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
        child: Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: message.reactions.entries
              .map((entry) => _buildReaction(entry.key, entry.value, theme))
              .toList(),
        ),
      );

  Widget _buildReaction(String emoji, List<String> users, ChatTheme theme) =>
      GestureDetector(
        onTap: () => onReactionTap?.call(emoji),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 14.0)),
              const SizedBox(width: 4.0),
              Text(
                users.length.toString(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
