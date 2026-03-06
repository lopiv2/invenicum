import 'dart:async';

import 'package:flutter/material.dart'; // <--- ESTA LÍNEA CORRIGE EL ERROR
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/container_provider.dart';

class InvenicumSearchBar extends StatefulWidget {
  const InvenicumSearchBar({super.key});

  @override
  State<InvenicumSearchBar> createState() => _InvenicumSearchBarState();
}

class _InvenicumSearchBarState extends State<InvenicumSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _results = [];
  Timer? _debounce;
  bool _isSearching = false; // Estado de carga

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    _controller.dispose();
    super.dispose();
  }

  // Método que llama a la lógica de búsqueda en el Provider
  void _onSearchChanged(String query) {
    // Cancelar el timer anterior si el usuario sigue escribiendo
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.length < 2) {
      setState(() => _isSearching = false);
      _hideOverlay();
      return;
    }

    // Iniciamos el timer de 500ms (Debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true); // Mostramos carga

      final results = await context.read<ContainerProvider>().searchAll(query);

      if (!mounted) return;

      setState(() {
        _results = results;
        _isSearching = false; // Quitamos carga
      });

      if (_results.isNotEmpty)
        _showOverlay();
      else
        _hideOverlay();
    });
  }

  void _showOverlay() {
    _hideOverlay();
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 400, // Ajusta según el diseño de tu Header
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 45),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return ListTile(
                    leading: Icon(item['icon'] as IconData, size: 20),
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item['subtitle'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      _hideOverlay();
                      _controller.clear();
                      context.go(item['route']); // Navega al elemento
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.lookForContainersOrAssets, // 👈 Traducción: Buscar contenedores o activos...
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (_controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : const Icon(Icons.search)),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
