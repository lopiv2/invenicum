import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaPaginationFooter extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaPaginationFooter({super.key, required this.stateManager});

  @override
  State<TrinaPaginationFooter> createState() => _TrinaPaginationFooterState();
}

class _TrinaPaginationFooterState extends State<TrinaPaginationFooter> {
  final TextEditingController _pageController = TextEditingController();
  static const List<int> _pageSizes = [10, 30, 50];
  late int _currentPage;
  late int _totalPages;
  late int _pageSize;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.stateManager.pageSize;
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
    _pageSize = widget.stateManager.pageSize;
  }

  void _setPageSize(int size) {
    widget.stateManager.setPageSize(size);
    widget.stateManager.setPage(1);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(l10n.rowsPerPageTitle, style: theme.textTheme.bodySmall),
          const SizedBox(width: 6),
          ..._pageSizes.map((size) => _buildPageSizeButton(size)),
          const SizedBox(width: 12),
          Expanded(
            child: TrinaPagination(widget.stateManager),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Text(l10n.goToPageLabel, style: theme.textTheme.bodySmall),
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

  Widget _buildPageSizeButton(int size) {
    final isActive = _pageSize == size;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => _setPageSize(size),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Text(
            size.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}