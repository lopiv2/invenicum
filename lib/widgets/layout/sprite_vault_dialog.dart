import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/constants.dart';

class SpriteVaultDialog extends StatefulWidget {
  const SpriteVaultDialog({super.key});

  @override
  State<SpriteVaultDialog> createState() => _SpriteVaultDialogState();
}

class _SpriteVaultDialogState extends State<SpriteVaultDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        width: 640,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: scheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, scheme),
            const Divider(height: 1),
            Expanded(child: _buildGrid(context, scheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        children: [
          Icon(Icons.videocam_rounded, color: scheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Sprite Vault™',
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ColorScheme scheme) {
    final arts = VersionArt.all;

    if (arts.isEmpty) {
      return Center(
        child: Text(
          'No sprites yet. Stay tuned for future versions!',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: arts.length,
      itemBuilder: (context, index) {
        final art = arts[index];
        return _SpriteCard(
          art: art,
          isCurrent: false,
          onTap: () => _openPreview(context, art),
        );
      },
    );
  }

  void _openPreview(BuildContext context, VersionArt art) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, _) => _SpritePreview(art: art),
      ),
    );
  }
}

class _SpriteCard extends StatelessWidget {
  final VersionArt art;
  final bool isCurrent;
  final VoidCallback onTap;

  const _SpriteCard({
    required this.art,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = 100.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? scheme.primary : scheme.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  art.assetPath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    Text(
                      art.versionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      art.versionName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (art.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        art.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpritePreview extends StatefulWidget {
  final VersionArt art;

  const _SpritePreview({required this.art});

  @override
  State<_SpritePreview> createState() => _SpritePreviewState();
}

class _SpritePreviewState extends State<_SpritePreview> {
  bool _isPlaying = true;
  ui.Image? _firstFrame;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFirstFrame();
  }

  Future<void> _loadFirstFrame() async {
    try {
      final data = await rootBundle.load(widget.art.assetPath);
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

  Future<void> _saveToDevice() async {
    setState(() => _saving = true);
    try {
      final data = await rootBundle.load(widget.art.assetPath);
      final tempDir = Directory.systemTemp;
      final fileName = widget.art.assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(data.buffer.asUint8List());
      if (!mounted) return;
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to ${file.path}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => setState(() => _isPlaying = !_isPlaying),
          ),
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _saving ? null : _saveToDevice,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(size),
            ),
            const SizedBox(height: 24),
            Text(
              widget.art.versionLabel,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.art.versionName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (widget.art.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.art.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    if (_isPlaying) {
      return Image.asset(
        widget.art.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    if (_firstFrame != null) {
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: RawImage(image: _firstFrame!),
        ),
      );
    }
    return SizedBox(width: size, height: size);
  }
}
