import 'package:flutter/material.dart';

class AssetFormLayout extends StatelessWidget {
  final Widget? aiBanner;
  final Widget? importBento; // Solo en Create
  final Widget mainDataBento;
  final Widget galleryBento;
  final Widget statusWidget;
  final Widget stockBento;
  final Widget? specsBento;
  final Widget? scraperBento;

  const AssetFormLayout({
    this.aiBanner,
    this.importBento,
    required this.mainDataBento,
    required this.galleryBento,
    required this.statusWidget,
    required this.stockBento,
    this.specsBento,
    this.scraperBento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Banner IA ──────────────────────────────────────────────────────
        if (aiBanner != null) ...[aiBanner!, const SizedBox(height: 24)],

        // ── Scraper (full width, solo si hay campos) ─────────────
        if (scraperBento != null) ...[
          const SizedBox(height: 24),
          scraperBento!,
        ],

        // ── Importar (solo create) ─────────────────────────────────────────
        if (importBento != null) ...[importBento!, const SizedBox(height: 24)],

        // ── Fila: Datos Principales (2/3) + Galería (1/3) ─────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // En pantallas anchas: side-by-side. En estrechas: apiladas.
            if (w >= 700) {
              final galleryWidth = (w * 0.35).clamp(260.0, 380.0);
              final mainWidth = w - galleryWidth - 24;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: mainWidth, child: mainDataBento),
                  const SizedBox(width: 24),
                  SizedBox(width: galleryWidth, child: galleryBento),
                ],
              );
            }
            return Column(
              children: [
                mainDataBento,
                const SizedBox(height: 16),
                galleryBento,
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // ── Fila: Estado (auto) + Stock (flex) ────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            if (w >= 600) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // StatusSectionWidget tiene su propio BentoBox internamente;
                    // lo envolvemos en Flexible para que tome el espacio justo.
                    Flexible(flex: 2, child: statusWidget),
                    const SizedBox(width: 24),
                    Flexible(flex: 3, child: stockBento),
                  ],
                ),
              );
            }
            return Column(
              children: [statusWidget, const SizedBox(height: 16), stockBento],
            );
          },
        ),

        // ── Especificaciones (full width, solo si hay campos) ─────────────
        if (specsBento != null) ...[const SizedBox(height: 24), specsBento!],
      ],
    );
  }
}
