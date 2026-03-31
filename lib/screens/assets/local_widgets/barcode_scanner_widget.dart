import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  const BarcodeScannerWidget({super.key});

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  // 🚩 El controlador se inicializa y se destruye aquí
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.all],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Opcional: Configurar para que el audio no se detenga bruscamente
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.start();
    });
  }

  // Método para disparar el sonido
  Future<void> _playScanSound() async {
    try {
      // Usamos AssetSource para apuntar a assets/audio/beep.mp3
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
      debugPrint("Error reproduciendo sonido: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _audioPlayer.dispose(); // 🚩 CRÍTICO: Liberar el recurso de audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          _buildHandle(colorScheme),
          _buildHeader(context),

          // 1. Mensaje de consejo para Web (Ahora como un elemento normal de la Column)
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  // Quitamos const de arriba si hay variables, pero aquí es estático
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.scannerFocusTip,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. El área del scanner
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
              ),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull?.rawValue;
                      if (barcode != null) {
                        _playScanSound();
                        HapticFeedback.mediumImpact();

                        // Damos un pequeño margen de 100ms para que el audio arranque
                        // antes de cerrar la pantalla y destruir el controlador.
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            Navigator.pop(context, barcode);
                          }
                        });
                      }
                    },
                  ),
                  // Guía visual (Esto sí está bien porque está dentro de un Stack)
                  Center(
                    child: Container(
                      width: 260,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.scanCodeTitle, style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
