import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:invenicum/config/environment.dart';
import 'package:url_launcher/url_launcher.dart';

class Model3DViewer extends StatelessWidget {
  const Model3DViewer({
    super.key,
    required this.src,
    this.title = '3D model',
    this.height = 360,
  });

  final String src;
  final String title;
  final double height;

  String get _resolvedSrc {
    if (src.startsWith('http://') || src.startsWith('https://')) return src;
    final host = Environment.apiUrl.endsWith('/')
        ? Environment.apiUrl.substring(0, Environment.apiUrl.length - 1)
        : Environment.apiUrl;
    return src.startsWith('/') ? '$host$src' : '$host/images/$src';
  }

  bool get _embeddedSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(_resolvedSrc);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!_embeddedSupported) {
      return SizedBox(
        height: height,
        child: Center(
          child: FilledButton.icon(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir modelo 3D'),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ModelViewer(
        src: _resolvedSrc,
        alt: title,
        autoRotate: true,
        cameraControls: true,
        ar: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
