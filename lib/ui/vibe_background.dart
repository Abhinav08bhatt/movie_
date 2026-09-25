import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Home vibe: poster → blur → Figma black gradient overlay.
class VibeBackground extends StatelessWidget {
  const VibeBackground({super.key, this.posterUrl});

  final String? posterUrl;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x4D373737), // 0%  #373737 @ 30%
      Color(0x802E2E2E), // 67% #2E2E2E @ 50%
      Color(0xBF282828), // 79% #282828 @ 75%
      Color(0xE6000000), // 90% #000000 @ 90%
      Color(0xFF000000), // 100%
    ],
    stops: [0.0, 0.67, 0.79, 0.90, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    if (posterUrl == null) {
      return const ColoredBox(color: Color(0xFF0F0F12));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: posterUrl!,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        const DecoratedBox(decoration: BoxDecoration(gradient: _gradient)),
      ],
    );
  }
}
