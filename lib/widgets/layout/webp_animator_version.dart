import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebpAnimatorVersion extends StatefulWidget {
  final String assetPath;
  final String versionText;
  final double? size;

  const WebpAnimatorVersion({
    super.key,
    required this.assetPath,
    required this.versionText,
    this.size,
  });

  @override
  State<WebpAnimatorVersion> createState() => _WebpAnimatorVersionState();
}

class _WebpAnimatorVersionState extends State<WebpAnimatorVersion> {
  bool _isPlaying = true;
  ui.Image? _firstFrame;

  @override
  void initState() {
    super.initState();
    _loadFirstFrame();
  }

  Future<void> _loadFirstFrame() async {
    try {
      final data = await rootBundle.load(widget.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frameInfo = await codec.getNextFrame();
      if (mounted) {
        setState(() => _firstFrame = frameInfo.image);
      }
      codec.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    _firstFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = widget.size ?? MediaQuery.of(context).size.width / 6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImage(size),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.versionText,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              ),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              color: colorScheme.primary,
              onPressed: () => setState(() => _isPlaying = !_isPlaying),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(double size) {
    if (_isPlaying) {
      return Image.asset(
        widget.assetPath,
        width: size,
        height: size,
      );
    }
    if (_firstFrame != null) {
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: RawImage(image: _firstFrame!),
        ),
      );
    }
    return SizedBox(width: size, height: size);
  }
}
