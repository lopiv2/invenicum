import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/l10n/app_localizations.dart';

const String _kCreateNew = '__create_new__';

class AppDropdownField<T> extends StatefulWidget {
  final String label;
  final bool isRequired;
  final List<T> values;
  final String Function(T) itemLabel;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String? addNewDialogTitle;
  final String? addNewHint;
  final Future<T?> Function(String name)? onAddNew;
  final Widget? addNewExtraContent;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.values,
    required this.itemLabel,
    required this.selectedValue,
    required this.onChanged,
    this.isRequired = false,
    this.validator,
    this.addNewDialogTitle,
    this.addNewHint,
    this.onAddNew,
    this.addNewExtraContent,
  });

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  final _formFieldKey = GlobalKey<FormFieldState<T>>();
  final _anchorKey = GlobalKey(); // para medir posición del campo
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  bool get _canAddNew =>
      widget.onAddNew != null && widget.addNewDialogTitle != null;

  // ─── Overlay ──────────────────────────────────────────────────────────────

  void _openOverlay() {
    if (_isOpen) return;

    final renderBox =
        _anchorKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;

    // Espacio disponible abajo y arriba
    final spaceBelow = screenH - offset.dy - size.height;
    final spaceAbove = offset.dy;
    final openUpward = spaceBelow < 240 && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(
        anchorOffset: offset,
        anchorWidth: size.width,
        anchorHeight: size.height,
        openUpward: openUpward,
        values: widget.values,
        itemLabel: widget.itemLabel,
        selectedValue: widget.selectedValue,
        canAddNew: _canAddNew,
        onSelected: _onItemSelected,
        onDismiss: _closeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (mounted) setState(() {});
  }

  void _onItemSelected(String? raw) {
    _closeOverlay();
    if (raw == null) return;

    if (raw == _kCreateNew) {
      _handleCreateNew(context);
      return;
    }

    final seen = <String>{};
    final unique = widget.values
        .where((v) => seen.add(widget.itemLabel(v)))
        .toList();
    final match = unique.firstWhere(
      (v) => widget.itemLabel(v) == raw,
      orElse: () => unique.first,
    );
    widget.onChanged(match);
    _formFieldKey.currentState?.didChange(match);
  }

  // ─── Add new dialog (sin cambios) ─────────────────────────────────────────

  Future<void> _handleCreateNew(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final addFn = widget.onAddNew!;

    await showAppDialog<void>(
      context: context,
      title: widget.addNewDialogTitle!,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: widget.addNewHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.pleaseEnterAName
                  : null,
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) Navigator.pop(context);
              },
            ),
            if (widget.addNewExtraContent != null) ...[
              const SizedBox(height: 16),
              widget.addNewExtraContent!,
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(context);
          },
          child: Text(l10n.create),
        ),
      ],
    );

    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final created = await addFn(name);
    if (created != null) {
      widget.onChanged(created);
      _formFieldKey.currentState?.didChange(created);
    }
  }

  // ─── Decoración ───────────────────────────────────────────────────────────

  InputDecoration _decoration(BuildContext context, {String? errorText}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.expand_circle_down_outlined, size: 20),
      suffixIcon: widget.selectedValue != null
          ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              tooltip: 'Limpiar',
              onPressed: () {
                widget.onChanged(null);
                _formFieldKey.currentState?.didChange(null);
              },
            )
          : AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.arrow_drop_down),
            ),
      helperText: widget.isRequired ? l10n.obligatory : null,
      helperMaxLines: 2,
      errorText: errorText,
      filled: true,
      fillColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<T>(
        key: _formFieldKey,
        initialValue: widget.selectedValue,
        validator: (v) {
          if (widget.validator != null) return widget.validator!(v);
          if (widget.isRequired && v == null) {
            return l10n.requiredFieldValidation;
          }
          return null;
        },
        builder: (fieldState) => GestureDetector(
          key: _anchorKey,
          onTap: _isOpen ? _closeOverlay : _openOverlay,
          child: InputDecorator(
            decoration: _decoration(
              context,
              errorText: fieldState.hasError ? fieldState.errorText : null,
            ),
            child: Text(
              widget.selectedValue != null
                  ? widget.itemLabel(widget.selectedValue as T)
                  : '',
              style: widget.selectedValue != null
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overlay widget ────────────────────────────────────────────────────────

class _DropdownOverlay<T> extends StatefulWidget {
  final Offset anchorOffset;
  final double anchorWidth;
  final double anchorHeight;
  final bool openUpward;
  final List<T> values;
  final String Function(T) itemLabel;
  final T? selectedValue;
  final bool canAddNew;
  final ValueChanged<String?> onSelected;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.anchorOffset,
    required this.anchorWidth,
    required this.anchorHeight,
    required this.openUpward,
    required this.values,
    required this.itemLabel,
    required this.selectedValue,
    required this.canAddNew,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  State<_DropdownOverlay<T>> createState() => _DropdownOverlayState<T>();
}

class _DropdownOverlayState<T> extends State<_DropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late List<T> _filtered;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Deduplicados una sola vez
  late final List<T> _unique;

  @override
  void initState() {
    super.initState();
    final seen = <String>{};
    _unique = widget.values
        .where((v) => seen.add(widget.itemLabel(v)))
        .toList();
    _filtered = _unique;

    _searchCtrl.addListener(_onSearch);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.92, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _animCtrl.forward();

    // Autofocus al campo de búsqueda tras el primer frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocus.requestFocus(),
    );
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _unique
          : _unique
                .where((v) => widget.itemLabel(v).toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Posición del panel
    double panelMaxH = MediaQuery.of(context).size.height / 20;
    double gap = MediaQuery.of(context).size.width / 32;

    final top = widget.openUpward
        ? widget.anchorOffset.dy + panelMaxH - gap
        : widget.anchorOffset.dy + widget.anchorHeight - gap;

    return Stack(
      children: [
        // Barrera transparente para cerrar al tocar fuera
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),

        // Panel
        Positioned(
          top: top,
          left:
              widget.anchorOffset.dx - MediaQuery.of(context).size.width / 6.5,
          width: widget.anchorWidth,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: widget.openUpward
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Campo de búsqueda ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: l10n.searchByName,
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: _searchCtrl.clear,
                                )
                              : null,
                          isDense: true,
                          filled: true,
                          fillColor: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.08,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // ── Lista ──
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 7,
                      ),
                      child: _filtered.isEmpty && !widget.canAddNew
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.noResultsFound,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.only(bottom: 6),
                              shrinkWrap: true,
                              children: [
                                ..._filtered.map((v) {
                                  final lbl = widget.itemLabel(v);
                                  final isSelected =
                                      widget.selectedValue != null &&
                                      widget.itemLabel(
                                            widget.selectedValue as T,
                                          ) ==
                                          lbl;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.onSelected(lbl),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 11,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lbl,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : null,
                                                    color: isSelected
                                                        ? colorScheme.primary
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check,
                                              size: 16,
                                              color: colorScheme.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                if (widget.canAddNew) ...[
                                  if (_filtered.isNotEmpty)
                                    Divider(
                                      height: 1,
                                      indent: 14,
                                      endIndent: 14,
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.onSelected(_kCreateNew),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 11,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 18,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.newLabel,
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
