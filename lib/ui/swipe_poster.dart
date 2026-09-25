import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';

class SwipePoster extends StatefulWidget {
  const SwipePoster({
    super.key,
    required this.movie,
    required this.onPass,
    required this.onWishlist,
    required this.onOpen,
  });

  final Movie movie;
  final VoidCallback onPass;
  final VoidCallback onWishlist;
  final VoidCallback onOpen;

  @override
  State<SwipePoster> createState() => _SwipePosterState();
}

class _SwipePosterState extends State<SwipePoster>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  late final AnimationController _controller;
  Animation<double>? _settle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final settle = _settle;
        if (settle != null) {
          setState(() => _dx = settle.value);
        }
      });
  }

  @override
  void didUpdateWidget(covariant SwipePoster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.id != widget.movie.id) {
      _dx = 0;
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dx += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    if (_dx > 110 || vx > 800) {
      _flingOff(1, widget.onWishlist);
    } else if (_dx < -110 || vx < -800) {
      _flingOff(-1, widget.onPass);
    } else {
      _animateTo(0);
    }
  }

  Future<void> _flingOff(int direction, VoidCallback done) async {
    final width = MediaQuery.sizeOf(context).width;
    await _animateTo(direction * (width + 80));
    if (!mounted) return;
    done();
  }

  Future<void> _animateTo(double target) async {
    _settle = Tween<double>(begin: _dx, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    await _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dx / 140).clamp(-1.0, 1.0);
    final angle = _dx / 1400;

    return GestureDetector(
      onTap: _dx.abs() < 8 ? widget.onOpen : null,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: Offset(_dx, 0),
        child: Transform.rotate(
          angle: angle,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: CachedNetworkImage(
                      imageUrl: widget.movie.posterUrl!,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                    ),
                  ),
                ),
                if (progress > 0.05)
                  _SwipeStamp(
                    label: 'wishlist',
                    color: const Color(0xFFE2F163),
                    opacity: progress,
                    alignment: Alignment.centerLeft,
                  ),
                if (progress < -0.05)
                  _SwipeStamp(
                    label: 'pass',
                    color: const Color(0xFF9AA0A6),
                    opacity: -progress,
                    alignment: Alignment.centerRight,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.opacity,
    required this.alignment,
  });

  final String label;
  final Color color;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
