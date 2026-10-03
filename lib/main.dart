import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFB6C2A7);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSL Scroll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
      ),
      home: const HslScrollPage(),
    );
  }
}

class HslScrollPage extends StatefulWidget {
  const HslScrollPage({super.key});

  @override
  State<HslScrollPage> createState() => _HslScrollPageState();
}

class _HslScrollPageState extends State<HslScrollPage> {
  static const int _itemCount = 50;

  final ScrollController _controller = ScrollController();
  final HSLColor _base = HSLColor.fromColor(primaryColor);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Scroll progress from 0.0 (top) to 1.0 (bottom).
  double get _progress {
    if (!_controller.hasClients) return 0;
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return 0;
    return (_controller.offset / max).clamp(0.0, 1.0);
  }

  /// Shifts the primary color's HSL values based on scroll progress.
  /// [shift] adds an extra per-item hue offset so rows differ slightly.
  HSLColor _colorFor(double progress, {double shift = 0}) {
    // final hue = _base.hue;
    final saturation = _base.saturation;
    final lightness = _base.lightness;
    final hue = (_base.hue + progress * 360 + shift) % 360;
    // final saturation = (_base.saturation + progress * 0.5).clamp(0.0, 1.0);
    // final lightness = (_base.lightness - progress * 0.3).clamp(0.0, 1.0);
    return HSLColor.fromAHSL(1, hue, saturation, lightness);
  }

  Color _textColorOn(HSLColor bg) =>
      bg.lightness > 0.55 ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final progress = _progress;
        final headerColor = _colorFor(progress);

        return Scaffold(
          backgroundColor: _colorFor(progress)
              .withLightness((headerColor.lightness + 0.2).clamp(0.0, 0.95))
              .toColor(),
          appBar: AppBar(
            backgroundColor: headerColor.toColor(),
            foregroundColor: _textColorOn(headerColor),
            title: Text(
              'H ${headerColor.hue.toStringAsFixed(0)}°  '
              'S ${(headerColor.saturation * 100).toStringAsFixed(0)}%  '
              'L ${(headerColor.lightness * 100).toStringAsFixed(0)}%',
            ),
          ),
          body: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              final color = _colorFor(progress, shift: index * 4.0);
              return _PostCard(
                index: index,
                color: color,
                textColor: _textColorOn(color),
              );
            },
          ),
        );
      },
    );
  }
}

/// An Instagram-style post: header, square HSL "image", actions and caption.
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.index,
    required this.color,
    required this.textColor,
  });

  final int index;
  final HSLColor color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final hsl =
        'hsl(${color.hue.toStringAsFixed(0)}, '
        '${(color.saturation * 100).toStringAsFixed(0)}%, '
        '${(color.lightness * 100).toStringAsFixed(0)}%)';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, username, menu.
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.toColor(),
              child: Text(
                '${index + 1}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              'user_${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Scroll Gallery'),
            trailing: const Icon(Icons.more_horiz),
          ),

          // Square "photo" filled with the scroll-driven HSL color.
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: color.toColor(),
              alignment: Alignment.center,
              child: Text(
                hsl,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Action row.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                ),
              ],
            ),
          ),

          // Likes + caption.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(index + 1) * 37} likes',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'user_${index + 1} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: 'Current color is $hsl'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
