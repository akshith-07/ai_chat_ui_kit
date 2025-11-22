import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_highlighter/themes/github-dark.dart';

/// A widget that displays code with syntax highlighting and a copy button.
///
/// Supports multiple programming languages and provides a copy-to-clipboard
/// functionality.
///
/// Example:
/// ```dart
/// CodeBlockWidget(
///   code: 'print("Hello World")',
///   language: 'python',
/// )
/// ```
class CodeBlockWidget extends StatefulWidget {
  /// Creates a code block widget.
  const CodeBlockWidget({
    required this.code,
    this.language = 'text',
    this.isDarkMode = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.showCopyButton = true,
    super.key,
  });

  /// The code to display
  final String code;

  /// Programming language for syntax highlighting
  final String language;

  /// Whether to use dark mode theme
  final bool isDarkMode;

  /// Background color of the code block
  final Color? backgroundColor;

  /// Text color (used when no syntax highlighting)
  final Color? textColor;

  /// Border radius of the code block
  final double borderRadius;

  /// Whether to show the copy button
  final bool showCopyButton;

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _copied = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _copied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        widget.backgroundColor ??
            (widget.isDarkMode
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFF5F5F5));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color:
              widget.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color:
                  widget.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.borderRadius),
                topRight: Radius.circular(widget.borderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.language,
                  style: TextStyle(
                    color:
                        widget.isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.showCopyButton)
                  InkWell(
                    onTap: _copyToClipboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _copied
                                ? Colors.green.shade100
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 14.0,
                            color:
                                _copied
                                    ? Colors.green
                                    : (widget.isDarkMode
                                        ? Colors.white70
                                        : Colors.black54),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            _copied ? 'Copied!' : 'Copy',
                            style: TextStyle(
                              color:
                                  _copied
                                      ? Colors.green
                                      : (widget.isDarkMode
                                          ? Colors.white70
                                          : Colors.black54),
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12.0),
            child: HighlightView(
              widget.code,
              language: widget.language,
              theme: widget.isDarkMode ? githubDarkTheme : githubTheme,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
