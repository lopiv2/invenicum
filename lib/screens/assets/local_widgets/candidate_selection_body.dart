import 'package:flutter/material.dart';
import 'package:invenicum/data/services/integrations_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/candidate_card_widget.dart';

class CandidateSelectionBody extends StatefulWidget {
  final List<Map<String, dynamic>> initialCandidates;
  final String source;
  final String query;
  final String locale;
  final int initialPage;
  final int pageSize;
  final bool initialHasMore;
  final Map<String, List<String>>? dropdownContext;
  final IntegrationService integrationService;
  final String Function(Map<String, dynamic>) buildCandidateSubtitle;

  const CandidateSelectionBody({
    super.key,
    required this.initialCandidates,
    required this.source,
    required this.query,
    required this.locale,
    required this.initialPage,
    required this.pageSize,
    required this.initialHasMore,
    this.dropdownContext,
    required this.integrationService,
    required this.buildCandidateSubtitle,
  });

  @override
  State<CandidateSelectionBody> createState() => _CandidateSelectionBodyState();
}

class _CandidateSelectionBodyState extends State<CandidateSelectionBody> {
  late List<Map<String, dynamic>> _candidates;
  late int _page;
  late bool _hasMore;
  bool _isLoading = false;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _candidates = widget.initialCandidates;
    _page = widget.initialPage;
    _hasMore = widget.initialHasMore;
  }

  Future<void> _goToPage(int newPage) async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.integrationService.enrichItem(
        query: widget.query,
        source: widget.source,
        locale: widget.locale,
        page: newPage,
        dropdownContext: widget.dropdownContext,
      );
      if (data != null && data['candidates'] != null) {
        final rawList = data['candidates'] as List;
        final normalized = rawList.map((e) {
          if (e is Map<String, dynamic>) return e;
          return <String, dynamic>{};
        }).toList();
        if (mounted) {
          setState(() {
            _candidates = normalized;
            _page = newPage;
            _hasMore = data['hasMore'] as bool? ?? false;
            _selectedId = null;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _candidates.isEmpty
                    ? Center(child: Text(l10n.noResultsFound))
                    : GridView.builder(
                        shrinkWrap: true,
                        itemCount: _candidates.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final candidate = _candidates[index];
                          final subtitle =
                              widget.buildCandidateSubtitle(candidate);
                          return CandidateCard(
                            candidate: candidate,
                            subtitle: subtitle,
                            isSelected: _selectedId == candidate['id'],
                            onTap: () =>
                                Navigator.of(context).pop(candidate),
                          );
                        },
                      ),
          ),
          if (_candidates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _page > 1 && !_isLoading
                        ? () => _goToPage(_page - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                  Text(
                    'Página $_page',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    onPressed: _hasMore && !_isLoading
                        ? () => _goToPage(_page + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Siguiente'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
