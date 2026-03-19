import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Footer de paginación personalizado para PlutoGrid.
/// Combina la paginación nativa con un campo "ir a página".
class PlutoPaginationFooter extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoPaginationFooter({super.key, required this.stateManager});

  @override
  State<PlutoPaginationFooter> createState() => _PlutoPaginationFooterState();
}

class _PlutoPaginationFooterState extends State<PlutoPaginationFooter> {
  final TextEditingController _pageController = TextEditingController();
  late int _currentPage;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _sync();
    widget.stateManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.stateManager.removeListener(_onStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(_sync);
  }

  void _sync() {
    _currentPage = widget.stateManager.page;
    _totalPages = widget.stateManager.totalPage;
  }

  void _goToPage(String value) {
    final page = int.tryParse(value.trim());
    if (page == null || page < 1 || page > _totalPages) {
      _pageController.clear();
      return;
    }
    widget.stateManager.setPage(page);
    _pageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PlutoPagination(widget.stateManager),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Text('Ir a página:', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 30,
            child: TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                hintText: '$_currentPage',
                hintStyle:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onSubmitted: _goToPage,
            ),
          ),
          const SizedBox(width: 6),
          Text('/ $_totalPages', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}