import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (movie.posterUrl != null)
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.52,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: movie.posterUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                  Color(0xCC000000),
                  Colors.black,
                  Colors.black,
                ],
                stops: [0.18, 0.32, 0.42, 0.52, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    children: [
                      _LogoOrTitle(movie: movie),
                      const SizedBox(height: 10),
                      Text(
                        '${movie.year}  ·  ★ ${movie.ratingLabel}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      if (movie.genres.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: movie.genres
                              .take(3)
                              .map((g) => _GenreChip(label: g))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ExpandableText(text: movie.overview),
                      const SizedBox(height: 22),
                      const _StaticActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.black, width: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoOrTitle extends StatelessWidget {
  const _LogoOrTitle({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    if (movie.logoUrl != null) {
      return SizedBox(
        height: 72,
        child: CachedNetworkImage(
          imageUrl: movie.logoUrl!,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          errorWidget: (_, _, _) => _TitleText(title: movie.title),
        ),
      );
    }
    return _TitleText(title: movie.title);
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _StaticActions extends StatelessWidget {
  const _StaticActions();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OutlineButton(
                label: 'Add to Wishlist',
                color: Color(0xFFE2F163),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _OutlineButton(
                label: 'Download list',
                color: Color(0xFF4DA3FF),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _OutlineButton(
          label: 'Mark as Watched',
          color: Color(0xFF3DDCFF),
        ),
        SizedBox(height: 12),
        _NoteBox(),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.85), width: 1.4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'add your note...',
        style: TextStyle(color: Colors.white38),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText({super.key, required this.text});

  final String text;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim().isEmpty
        ? 'no description for this one.'
        : widget.text.trim();

    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: _expanded ? 20 : 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            height: 1.35,
            fontSize: 14,
          ),
        ),
        if (!_expanded && text.length > 180)
          TextButton(
            onPressed: () => setState(() => _expanded = true),
            child: const Text(
              '... more ...',
              style: TextStyle(color: Colors.white54),
            ),
          ),
      ],
    );
  }
}
