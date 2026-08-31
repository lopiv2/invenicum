# FloatingOverlayImage — working baseline

## File
`lib/widgets/layout/floating_overlay_image.dart`

## Date saved
2026-05-19 (v1: Timer.periodic, v2: flutter_animate — reverted, v2 had first-frame issue with Animate widget)

## Description
Timer.periodic-based animation for cross-toons that float across the screen.
Uses server-provided images from `PreferencesProvider.crossToonConfigs`.

## Movement engine (Timer.periodic)
- `_animTimer` + `_dx` drive position pixel-by-pixel
- `_onTick` checks crossing manually every `tickMs`
- `_dx = (totalPx / totalTicks) * direction`
- On turn: `_dx = -_dx`, swap origin/target
- `setState(() {})` on each tick for rebuild
- `Transform.translate(Offset(_x, 0))` in build

## Image loading logic
- `data:` → `Image.memory` (freshly picked, before server save)
- `assets/` → `Image.asset` (legacy local assets)
- anything else (e.g. `images/cross-toons/xxx.webp`) → `Image.network`
  - Strips `images/` or `/images/` prefix from the server path before constructing the URL to avoid doubling `/images/`
  - URL: `${Environment.apiUrl}/images/$relative`

## Cross-toon settings UI
`lib/screens/preferences/local_widgets/cross_toons_card_widget.dart`

## Important notes
- The cross-toon configs come from `context.watch<PreferencesProvider>().crossToonConfigs`
- `PreferencesProvider` loads them via `GET /preferences` (returned in `crossToonConfigs` field)
- Frequency is configured per cross-toon in the settings dialog (seconds between appearances)
- Turn mode: `TurnMode.off` / `TurnMode.on` / `TurnMode.random`
- The `_buildPreview` in `cross_toons_card_widget.dart` has the same `images/` prefix issue as the overlay
- `didUpdateWidget` added so when configs arrive from server (initially empty), the first cross-toon is scheduled

## Correccion de problemas y cosas que hacer
- Siempre, cuando acabes de darme la respuesta, corrige los problemas generados con la solución, si se puede, y no lo dejes
- Si puedes, utiliza parametros de widgets que no este deprecados, y si los hay, a posteriori, hay que corregirlos
- Siempre hay que traducir cadenas con ARB cuando se haga codigo nuevo, no hardcodear cadenas de texto
- Siempre usar ToastService para notificaciones, no usar otra cosa.
