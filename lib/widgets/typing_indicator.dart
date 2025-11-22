import 'package:flutter/material.dart';
import 'dart:math' as math;

/// An animated typing indicator showing that the AI is composing a response.
///
/// Displays three animated dots that pulse in sequence.
///
/// Example:
/// ```dart
/// TypingIndicator(
///   dotColor: Colors.grey,
///   dotSize: 8.0,
/// )
/// ```
class TypingIndicator extends StatefulWidget {
  /// Creates a typing indicator.
  const TypingIndicator({
    this.dotColor,
    this.dotSize = 8.0,
    this.animationDuration = const Duration(milliseconds: 1400),
    super.key,
  });

  /// Color of the typing indicator dots
  final Color? dotColor;

  /// Size of each dot
  final double dotSize;

  /// Duration of the complete animation cycle
  final Duration animationDuration;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor = widget.dotColor ?? Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildDot(0, dotColor),
        SizedBox(width: widget.dotSize * 0.5),
        _buildDot(1, dotColor),
        SizedBox(width: widget.dotSize * 0.5),
        _buildDot(2, dotColor),
      ],
    );
  }

  Widget _buildDot(int index, Color color) => AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double offset = (index * 0.2);
          final double animationValue =
              math.max(
                0.0,
                math.min(
                  1.0,
                  (_controller.value - offset) * 2.5,
                ),
              );
          final double scale =
              0.6 + (math.sin(animationValue * math.pi) * 0.4);
          final double opacity =
              0.4 + (math.sin(animationValue * math.pi) * 0.6);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
}
