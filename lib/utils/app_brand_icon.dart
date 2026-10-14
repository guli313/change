import 'package:flutter/material.dart';

/// Reusable App Icon widget for top headers and AppBars
class AppBrandIcon extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showBorder;

  const AppBrandIcon({
    super.key,
    this.size = 28,
    this.borderRadius = 8,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset(
      'assets/icons/appicon.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
    );

    if (borderRadius > 0) {
      img = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: img,
      );
    }

    if (showBorder) {
      img = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius + 2),
          border: Border.all(
            color: const Color(0xFFCBA35C).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: img,
      );
    }

    return img;
  }
}

/// Reusable AppBar title with App Icon on the left
class AppBrandTitle extends StatelessWidget {
  final String title;
  final double iconSize;
  final TextStyle? style;

  const AppBrandTitle({
    super.key,
    required this.title,
    this.iconSize = 26,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBrandIcon(size: iconSize),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: style ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
