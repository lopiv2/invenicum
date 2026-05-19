import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/overlay_image_config_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:provider/provider.dart';

class CrossToonsCardWidget extends StatelessWidget {
  const CrossToonsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefsProv = context.watch<PreferencesProvider>();
    final customConfigs = prefsProv.crossToonConfigs;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.crossToonsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: l10n.crossToonsAddNew,
                  onPressed: () => _addCrossToon(context, prefsProv),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.crossToonsDescription,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).hintColor,
              ),
            ),
            if (customConfigs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.crossToonsAddNew,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              )
            else
              ...customConfigs.asMap().entries.map(
                    (entry) => _CrossToonTile(
                      index: entry.key,
                      config: entry.value,
                      onEdit: entry.value.isDefault
                          ? null
                          : () => _editCrossToon(
                                context, prefsProv, entry.key, entry.value,
                              ),
                      onDelete: entry.value.isDefault
                          ? null
                          : () => prefsProv.removeCrossToonConfig(entry.key),
                      onToggle: entry.value.isDefault
                          ? null
                          : (v) => prefsProv.toggleCrossToonEnabled(entry.key, v ?? false),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<({Uint8List bytes, String name})?> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.first.bytes != null) {
      return (
        bytes: result.files.first.bytes!,
        name: result.files.first.name,
      );
    }
    return null;
  }

  void _addCrossToon(BuildContext context, PreferencesProvider prefsProv) {
    _showConfigDialog(
      context,
      prefsProv,
      null,
      null,
      ({required Uint8List? bytes, required String? name, required OverlayImageConfig config}) async {
        if (bytes == null || name == null) return;
        await prefsProv.addCrossToonConfig(
          imageBytes: bytes,
          imageName: name,
          config: config,
        );
      },
    );
  }

  void _editCrossToon(
    BuildContext context,
    PreferencesProvider prefsProv,
    int index,
    OverlayImageConfig config,
  ) {
    _showConfigDialog(
      context,
      prefsProv,
      config,
      index,
      ({required Uint8List? bytes, required String? name, required OverlayImageConfig config}) async {
        await prefsProv.updateCrossToonConfig(
          index: index,
          config: config,
          imageBytes: bytes,
          imageName: name,
        );
      },
    );
  }

  void _showConfigDialog(
    BuildContext context,
    PreferencesProvider prefsProv,
    OverlayImageConfig? existing,
    int? editIndex,
    Future<void> Function({
      required Uint8List? bytes,
      required String? name,
      required OverlayImageConfig config,
    }) onSave,
  ) {
    final speedCtrl = TextEditingController(
      text: (existing?.speed.inSeconds ?? 30).toString(),
    );
    final freqCtrl = TextEditingController(
      text: (existing?.frequency.inSeconds ?? 10).toString(),
    );
    final sizeCtrl = TextEditingController(
      text: (existing?.imageSize ?? 150).toStringAsFixed(0),
    );
    final fpsCtrl = TextEditingController(
      text: (existing?.animationFps ?? 30).toString(),
    );
    final minTurnCtrl = TextEditingController(
      text: (existing?.turnMinDelay ?? 5).toString(),
    );
    final maxTurnCtrl = TextEditingController(
      text: (existing?.turnMaxDelay ?? 8).toString(),
    );
    final maxTurnsCtrl = TextEditingController(
      text: (existing?.maxTurns ?? 1).toString(),
    );

    var direction = existing?.direction ?? AnimationDirection.alternate;
    var zone = existing?.zone ?? OverlayZone.random;
    var turnMode = existing?.turnMode ?? TurnMode.on;

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        Uint8List? pickedBytes;
        String? pickedName;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            ImageProvider resolveImage() {
              if (pickedBytes != null) {
                return MemoryImage(pickedBytes!);
              }
              final path = existing?.imagePath;
              if (path == null || path.isEmpty) {
                return const AssetImage('');
              }
              if (path.startsWith('data:')) {
                return MemoryImage(
                  Uint8List.fromList(path.split(',').last.codeUnits),
                );
              }
              if (path.startsWith('assets/') || path.startsWith('images/')) {
                return AssetImage(path);
              }
              final normalized =
                  path.startsWith('/images/') ? path.substring(8) : path;
              return NetworkImage('${Environment.apiUrl}/images/$normalized');
            }

            return AlertDialog(
              title: Text(existing != null
                  ? l10n.crossToonsConfigure
                  : l10n.crossToonsAddNew),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: l10n.crossToonsImageLabel,
                              hintText: existing != null
                                  ? existing.imagePath.split('/').last
                                  : l10n.crossToonsImageHint,
                              isDense: true,
                            ),
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.image_outlined),
                          onPressed: () async {
                            final result = await _pickImage();
                            if (result != null) {
                              setDialogState(() {
                                pickedBytes = result.bytes;
                                pickedName = result.name;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (pickedBytes != null && pickedName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          pickedName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _PreviewAnimation(
                      image: resolveImage(),
                      imageSize: double.tryParse(sizeCtrl.text) ?? 150,
                      speed: Duration(
                        seconds:
                            int.tryParse(speedCtrl.text)?.clamp(1, 120) ?? 8,
                      ),
                      direction: direction,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AnimationDirection>(
                      initialValue: direction,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsDirectionLabel,
                        isDense: true,
                      ),
                      items: AnimationDirection.values.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => direction = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<OverlayZone>(
                      initialValue: zone,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsZoneLabel,
                        isDense: true,
                      ),
                      items: OverlayZone.values.map((z) {
                        return DropdownMenuItem(value: z, child: Text(z.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => zone = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: speedCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsSpeedLabel,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: freqCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsFrequencyLabel,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sizeCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsImageSizeLabel,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fpsCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsFpsLabel,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TurnMode>(
                      decoration: InputDecoration(
                        labelText: l10n.crossToonsTurnModeLabel,
                        isDense: true,
                      ),
                      items: TurnMode.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => turnMode = v);
                      },
                    ),
                    if (turnMode == TurnMode.on) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: minTurnCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.crossToonsTurnMinDelayLabel,
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: maxTurnCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.crossToonsTurnMaxDelayLabel,
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: maxTurnsCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.crossToonsMaxTurnsLabel,
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    if (existing == null &&
                        (pickedBytes == null || pickedName == null)) return;
                    final config = OverlayImageConfig(
                      imagePath: existing?.imagePath ?? '',
                      direction: direction,
                      zone: zone,
                      speed: Duration(
                        seconds: int.tryParse(speedCtrl.text) ?? 30,
                      ),
                      frequency: Duration(
                        seconds: int.tryParse(freqCtrl.text) ?? 10,
                      ),
                      imageSize: double.tryParse(sizeCtrl.text) ?? 150,
                      animationFps: int.tryParse(fpsCtrl.text) ?? 30,
                      turnMode: turnMode,
                      turnMinDelay: int.tryParse(minTurnCtrl.text) ?? 5,
                      turnMaxDelay: int.tryParse(maxTurnCtrl.text) ?? 8,
                      maxTurns: int.tryParse(maxTurnsCtrl.text) ?? 1,
                    );
                    Navigator.pop(ctx);
                    await onSave(
                      bytes: pickedBytes,
                      name: pickedName,
                      config: config,
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Preview animation ────────────────────────────────────────────────────────

class _PreviewAnimation extends StatefulWidget {
  final ImageProvider image;
  final double imageSize;
  final Duration speed;
  final AnimationDirection direction;

  const _PreviewAnimation({
    super.key,
    required this.image,
    required this.imageSize,
    required this.speed,
    required this.direction,
  });

  @override
  State<_PreviewAnimation> createState() => _PreviewAnimationState();
}

class _PreviewAnimationState extends State<_PreviewAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _x = 0;

  // True cuando el sprite debe estar volteado (moviéndose hacia la izquierda).
  bool _movingLeft = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _startAnimation();
  }

  @override
  void didUpdateWidget(_PreviewAnimation old) {
    super.didUpdateWidget(old);
    if (old.speed != widget.speed ||
        old.direction != widget.direction ||
        old.imageSize != widget.imageSize ||
        old.image != widget.image) {
      _startAnimation();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    // Para rightToLeft empieza moviéndose a la izquierda desde el inicio.
    // Para alternate empieza a la derecha (primera mitad), luego voltea.
    // Para leftToRight nunca voltea.
    _movingLeft = widget.direction == AnimationDirection.rightToLeft;

    final halfMs = widget.speed.inMilliseconds ~/ 2;
    _controller
      ..duration = Duration(milliseconds: halfMs.clamp(16, 60000))
      ..forward(from: 0);
  }

  void _onTick() {
    setState(() {
      _x = _controller.value;
      // En modo alternate: primera mitad va a la derecha, segunda a la izquierda.
      if (widget.direction == AnimationDirection.alternate) {
        _movingLeft = _x > 0.5;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double trackHeight = 100;
    const double trackWidth = 280;
    final imgSize = widget.imageSize.clamp(20.0, trackHeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.crossToonsPreviewLabel,
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 6),
        Container(
          width: trackWidth,
          height: trackHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerW = constraints.maxWidth.toDouble();
              final containerH = constraints.maxHeight.toDouble();
              final x = _computeX(containerW, imgSize);
              final y = (containerH - imgSize) / 2;

              return Stack(
                children: [
                  // Icono de dirección
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      widget.direction == AnimationDirection.leftToRight
                          ? Icons.arrow_forward
                          : widget.direction == AnimationDirection.rightToLeft
                              ? Icons.arrow_back
                              : Icons.swap_horiz,
                      size: 14,
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.4),
                    ),
                  ),
                  // Imagen con flip según dirección de movimiento
                  Positioned(
                    left: x,
                    top: y,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Transform.scale(
                        scaleX: _movingLeft ? -1 : 1,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: imgSize,
                          height: imgSize,
                          child: StaticPreview(
                            image: widget.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.direction.name} · ${widget.speed.inSeconds}s',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  double _computeX(double containerWidth, double imgSize) {
    final value = _x;
    final total = containerWidth + imgSize;
    switch (widget.direction) {
      case AnimationDirection.leftToRight:
        return -imgSize + total * value;
      case AnimationDirection.rightToLeft:
        return containerWidth - total * value;
      case AnimationDirection.alternate:
        if (value <= 0.5) {
          return -imgSize + total * (value * 2);
        } else {
          return containerWidth - total * ((value - 0.5) * 2);
        }
    }
  }
}

// ─── Static preview (primer frame del WebP/GIF) ───────────────────────────────

/// Resuelve un [ImageProvider] y renderiza solo el primer frame como imagen
/// estática. Evita que imágenes animadas (GIF, WebP) animen en previews.
class StaticPreview extends StatefulWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const StaticPreview({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<StaticPreview> createState() => _StaticPreviewState();
}

class _StaticPreviewState extends State<StaticPreview> {
  ImageInfo? _info;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(StaticPreview old) {
    super.didUpdateWidget(old);
    if (old.image != widget.image) {
      _info = null;
      _loaded = false;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final stream = widget.image.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    final listener = ImageStreamListener(
      (info, _) {
        if (!_loaded) {
          _info = info;
          _loaded = true;
          if (mounted) setState(() {});
        }
        completer.complete();
      },
      onError: (_, __) => completer.complete(),
    );
    stream.addListener(listener);
    await completer.future;
    stream.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (info == null) {
      return const Icon(Icons.image, size: 24);
    }
    return RawImage(
      image: info.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  @override
  void dispose() {
    _info?.dispose();
    super.dispose();
  }
}

// ─── Tile de lista ────────────────────────────────────────────────────────────

class _CrossToonTile extends StatelessWidget {
  final int? index;
  final OverlayImageConfig config;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onToggle;

  const _CrossToonTile({
    this.index,
    required this.config,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  Widget _buildPreview(String path) {
    if (path.startsWith('data:')) {
      return StaticPreview(
        image: MemoryImage(
          Uint8List.fromList(path.split(',').last.codeUnits),
        ),
        fit: BoxFit.cover,
      );
    }
    if (path.startsWith('images/') || path.startsWith('assets/')) {
      return StaticPreview(
        image: AssetImage(path),
        fit: BoxFit.contain,
      );
    }
    final normalized = path.startsWith('/images/') ? path.substring(8) : path;
    return StaticPreview(
      image: NetworkImage('${Environment.apiUrl}/images/$normalized'),
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fileName = config.imagePath.split('/').last;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 40,
              height: 40,
              child: _buildPreview(config.imagePath),
            ),
          ),
          title: Text(fileName, style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            '${config.direction.name} · ${config.zone.name} · ${config.speed.inSeconds}s',
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
          trailing: config.isDefault
              ? Icon(Icons.lock_outline,
                  size: 16, color: Theme.of(context).hintColor)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: l10n.disable,
                      child: Checkbox(
                        value: config.enabled,
                        onChanged: onToggle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}