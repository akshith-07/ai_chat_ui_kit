import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/chat_theme.dart';
import '../themes/chat_theme_provider.dart';
import '../utils/debouncer.dart';
import 'voice_input_button.dart';

/// A comprehensive message input widget with formatting and attachments.
///
/// Features:
/// - Multi-line text input with auto-expansion
/// - Text formatting toolbar (bold, italic, code)
/// - Attachment button for files and images
/// - Voice input integration
/// - @mention autocomplete
/// - Draft message persistence
///
/// Example:
/// ```dart
/// MessageInputComposer(
///   onSendMessage: (text) => sendMessage(text),
///   onAttachmentTap: () => pickFile(),
/// )
/// ```
class MessageInputComposer extends StatefulWidget {
  /// Creates a message input composer.
  const MessageInputComposer({
    required this.onSendMessage,
    this.onAttachmentTap,
    this.onVoiceInput,
    this.hintText = 'Type a message...',
    this.showFormatting = true,
    this.showAttachment = true,
    this.showVoiceInput = true,
    this.enableMentions = false,
    this.mentionSuggestions = const <String>[],
    this.onMentionSearch,
    this.persistDrafts = true,
    this.draftKey = 'chat_draft',
    this.textController,
    super.key,
  });

  /// Callback when a message is sent
  final void Function(String text) onSendMessage;

  /// Callback when attachment button is tapped
  final VoidCallback? onAttachmentTap;

  /// Callback when voice input is received
  final void Function(String text)? onVoiceInput;

  /// Placeholder text for the input field
  final String hintText;

  /// Whether to show the formatting toolbar
  final bool showFormatting;

  /// Whether to show the attachment button
  final bool showAttachment;

  /// Whether to show the voice input button
  final bool showVoiceInput;

  /// Whether to enable @mention autocomplete
  final bool enableMentions;

  /// List of mention suggestions
  final List<String> mentionSuggestions;

  /// Callback when searching for mentions
  final void Function(String query)? onMentionSearch;

  /// Whether to persist drafts between sessions
  final bool persistDrafts;

  /// Key for storing draft messages
  final String draftKey;

  /// Optional external text controller
  final TextEditingController? textController;

  @override
  State<MessageInputComposer> createState() => _MessageInputComposerState();
}

class _MessageInputComposerState extends State<MessageInputComposer> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showFormatBar = false;
  bool _canSend = false;
  String _mentionQuery = '';
  List<String> _filteredMentions = <String>[];
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = widget.textController ?? TextEditingController();
    _debouncer = Debouncer(milliseconds: 300);
    _controller.addListener(_onTextChanged);
    _loadDraft();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode.dispose();
    if (widget.textController == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  Future<void> _loadDraft() async {
    if (!widget.persistDrafts) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? draft = prefs.getString(widget.draftKey);
    if (draft != null && draft.isNotEmpty && mounted) {
      _controller.text = draft;
    }
  }

  Future<void> _saveDraft(String text) async {
    if (!widget.persistDrafts) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (text.isEmpty) {
      await prefs.remove(widget.draftKey);
    } else {
      await prefs.setString(widget.draftKey, text);
    }
  }

  void _onTextChanged() {
    final String text = _controller.text;
    final bool canSend = text.trim().isNotEmpty;

    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }

    // Handle mentions
    if (widget.enableMentions) {
      _handleMentions(text);
    }

    // Save draft
    _debouncer.run(() => _saveDraft(text));
  }

  void _handleMentions(String text) {
    final int cursorPosition = _controller.selection.baseOffset;
    if (cursorPosition <= 0) return;

    final String beforeCursor = text.substring(0, cursorPosition);
    final RegExp mentionRegex = RegExp(r'@(\w*)$');
    final RegExpMatch? match = mentionRegex.firstMatch(beforeCursor);

    if (match != null) {
      final String query = match.group(1) ?? '';
      if (query != _mentionQuery) {
        setState(() {
          _mentionQuery = query;
          _filteredMentions = widget.mentionSuggestions
              .where(
                (String name) =>
                    name.toLowerCase().contains(query.toLowerCase()),
              )
              .take(5)
              .toList();
        });
        widget.onMentionSearch?.call(query);
      }
    } else if (_mentionQuery.isNotEmpty) {
      setState(() {
        _mentionQuery = '';
        _filteredMentions.clear();
      });
    }
  }

  void _insertMention(String mention) {
    final String text = _controller.text;
    final int cursorPosition = _controller.selection.baseOffset;
    final String beforeCursor = text.substring(0, cursorPosition);
    final RegExp mentionRegex = RegExp(r'@\w*$');

    final String newBeforeCursor =
        beforeCursor.replaceFirst(mentionRegex, '@$mention ');
    final String newText = newBeforeCursor + text.substring(cursorPosition);

    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newBeforeCursor.length),
    );

    setState(() {
      _mentionQuery = '';
      _filteredMentions.clear();
    });
  }

  void _sendMessage() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text);
    _controller.clear();
    _saveDraft('');
    _focusNode.requestFocus();
  }

  void _applyFormatting(String format) {
    final TextSelection selection = _controller.selection;
    if (!selection.isValid) return;

    final String text = _controller.text;
    final String selectedText = selection.textInside(text);

    String formattedText;
    switch (format) {
      case 'bold':
        formattedText = '**$selectedText**';
        break;
      case 'italic':
        formattedText = '*$selectedText*';
        break;
      case 'code':
        formattedText = '`$selectedText`';
        break;
      default:
        return;
    }

    final String newText =
        text.replaceRange(selection.start, selection.end, formattedText);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + formattedText.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatTheme theme = ChatThemeProvider.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_filteredMentions.isNotEmpty) _buildMentionSuggestions(theme),
        if (_showFormatBar && widget.showFormatting) _buildFormatBar(theme),
        _buildInputRow(theme),
      ],
    );
  }

  Widget _buildMentionSuggestions(ChatTheme theme) => Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: theme.inputBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredMentions.length,
          itemBuilder: (BuildContext context, int index) {
            final String mention = _filteredMentions[index];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                child: Text(
                  mention[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(mention),
              onTap: () => _insertMention(mention),
            );
          },
        ),
      );

  Widget _buildFormatBar(ChatTheme theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: theme.inputBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildFormatButton(Icons.format_bold, 'bold', theme),
            _buildFormatButton(Icons.format_italic, 'italic', theme),
            _buildFormatButton(Icons.code, 'code', theme),
          ],
        ),
      );

  Widget _buildFormatButton(IconData icon, String format, ChatTheme theme) =>
      IconButton(
        icon: Icon(icon, size: 20.0),
        color: theme.iconColor,
        onPressed: () => _applyFormatting(format),
      );

  Widget _buildInputRow(ChatTheme theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.inputBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (widget.showAttachment)
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: theme.iconColor,
                onPressed: widget.onAttachmentTap,
              ),
            if (widget.showFormatting)
              IconButton(
                icon: Icon(_showFormatBar ? Icons.close : Icons.text_format),
                color: theme.iconColor,
                onPressed: () {
                  setState(() {
                    _showFormatBar = !_showFormatBar;
                  });
                },
              ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                  border: Border.all(color: theme.inputBorderColor),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: theme.inputTextColor,
                    fontSize: theme.inputFontSize,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: theme.iconColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            if (widget.showVoiceInput && !_canSend)
              VoiceInputButton(
                onTextRecognized: (String text) {
                  _controller.text += text;
                  widget.onVoiceInput?.call(text);
                },
                color: theme.iconColor,
              )
            else
              IconButton(
                icon: const Icon(Icons.send),
                color: _canSend ? theme.sendButtonColor : theme.sendButtonDisabledColor,
                onPressed: _canSend ? _sendMessage : null,
              ),
          ],
        ),
      );
}
