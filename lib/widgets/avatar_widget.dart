import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_user.dart';

/// A customizable avatar widget that displays user profile images.
///
/// Supports network images with caching, fallback to initials, and
/// online status indicators.
///
/// Example:
/// ```dart
/// AvatarWidget(
///   user: chatUser,
///   size: 40,
///   showOnlineIndicator: true,
/// )
/// ```
class AvatarWidget extends StatelessWidget {
  /// Creates an avatar widget.
  const AvatarWidget({
    required this.user,
    this.size = 32.0,
    this.shape = BoxShape.circle,
    this.borderRadius = 8.0,
    this.showOnlineIndicator = false,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  /// The user whose avatar to display
  final ChatUser user;

  /// Size of the avatar (width and height)
  final double size;

  /// Shape of the avatar (circle or rectangle)
  final BoxShape shape;

  /// Border radius when shape is rectangle
  final double borderRadius;

  /// Whether to show online status indicator
  final bool showOnlineIndicator;

  /// Background color for initials fallback
  final Color? backgroundColor;

  /// Text color for initials
  final Color? textColor;

  Color _getDefaultBackgroundColor() {
    final int hashCode = user.id.hashCode;
    final List<Color> colors = <Color>[
      const Color(0xFFE57373),
      const Color(0xFFF06292),
      const Color(0xFFBA68C8),
      const Color(0xFF9575CD),
      const Color(0xFF7986CB),
      const Color(0xFF64B5F6),
      const Color(0xFF4FC3F7),
      const Color(0xFF4DD0E1),
      const Color(0xFF4DB6AC),
      const Color(0xFF81C784),
      const Color(0xFFAED581),
      const Color(0xFFFFD54F),
      const Color(0xFFFFB74D),
      const Color(0xFFFF8A65),
    ];
    return colors[hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? _getDefaultBackgroundColor();
    final Color txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: shape,
              borderRadius:
                  shape == BoxShape.rectangle
                      ? BorderRadius.circular(borderRadius)
                      : null,
            ),
            child: user.avatar != null && user.avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        shape == BoxShape.rectangle
                            ? BorderRadius.circular(borderRadius)
                            : BorderRadius.circular(size / 2),
                    child: CachedNetworkImage(
                      imageUrl: user.avatar!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      placeholder:
                          (BuildContext context, String url) => Container(
                        color: bgColor,
                        child: Center(
                          child: Text(
                            user.initials,
                            style: TextStyle(
                              color: txtColor,
                              fontSize: size * 0.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      errorWidget:
                          (BuildContext context, String url, Object error) =>
                              Center(
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            color: txtColor,
                            fontSize: size * 0.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: txtColor,
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          if (showOnlineIndicator && user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: size * 0.05,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
