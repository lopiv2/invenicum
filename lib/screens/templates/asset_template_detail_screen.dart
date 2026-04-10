import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/data/models/asset_template_model.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetTemplateDetailScreen extends StatefulWidget {
  final String templateId;
  final AssetTemplate? initialTemplate;

  const AssetTemplateDetailScreen({
    super.key,
    required this.templateId,
    this.initialTemplate,
  });

  @override
  State<AssetTemplateDetailScreen> createState() =>
      _AssetTemplateDetailScreenState();
}

class _AssetTemplateDetailScreenState extends State<AssetTemplateDetailScreen> {
  AssetTemplate? _template;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.initialTemplate != null) {
      _template = widget.initialTemplate;

      // 🚩 KEY FIX:
      // If the object exists but the fields are empty,
      // it means it comes from the Market summary and we need to fetch the details.
      if (_template!.fields.isEmpty) {
        if (kDebugMode) {
          debugPrint("Incomplete structure, hydrating from server...");
        }
        await _fetchTemplateData();
      }
    } else {
      await _fetchTemplateData();
    }
  }

  Future<void> _fetchTemplateData() async {
    if (!mounted) return;
    setState(() => _isFetching = true);
    // Capture localizations before any `await` to avoid using BuildContext across async gaps.
    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = context.read<TemplateProvider>();
      // IMPORTANT: Ensure the provider returns the hydrated object
      final result = await provider.getTemplateById(widget.templateId);

      if (mounted) {
        setState(() {
          _template = result;
          _isFetching = false; // Clear the fetching flag here
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetching = false);
      ToastService.error(l10n.templateDetailFetchError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_template == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l10n.templateNotAvailable),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.backLabel),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templateDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: l10n.saveToLibraryTooltip,
            onPressed: () => _handleSaveOnly(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 20),
            Text(
              _template!.description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildTags(),
            const Divider(height: 40),
            _buildFieldsSection(l10n),
            const SizedBox(height: 100), // Space for the bottom button
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.indigo.shade100,
          // 🚩 backgroundImage handles the image if it exists
          backgroundImage:
              _template!.authorAvatarUrl != null &&
                  _template!.authorAvatarUrl!.isNotEmpty
              ? NetworkImage(_template!.authorAvatarUrl!)
              : null,
          // 🚩 child is shown only if the image fails or doesn't exist
          child:
              (_template!.authorAvatarUrl == null ||
                  _template!.authorAvatarUrl!.isEmpty)
              ? Text(
                  _template!.author[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _template!.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.templateByAuthor(_template!.author),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (_template!.isOfficial)
          Tooltip(
            message: l10n.officialVerifiedTemplate,
            child: Icon(Icons.verified, color: Colors.blue, size: 28),
          ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: _template!.tags
          .map(
            (tag) => Chip(
              label: Text('#$tag', style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildFieldsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Text(
              l10n.dataStructureFieldsUpper(_template!.fields.length),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _template!.fields.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final field = _template!.fields[index];
            String optionsText = "";
            if (field.type == CustomFieldType.dropdown &&
                field.options != null &&
                field.options!.isNotEmpty) {
              optionsText = " (${field.options!.join(', ')})";
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.drag_indicator,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🚩 Field name + options (if any)
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: field.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (optionsText.isNotEmpty)
                                TextSpan(
                                  text: optionsText,
                                  style: TextStyle(
                                    color: Colors.indigo.shade400,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          field.type.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (field.isRequired)
                    const Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showInstallDialog(),
          icon: const Icon(Icons.download_for_offline_rounded),
          label: Text(
            AppLocalizations.of(context)!.installInMyInventoryUpper,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIC ---

  Future<void> _handleSaveOnly() async {
    final tProvider = context.read<TemplateProvider>();
    final l10n = AppLocalizations.of(context)!;
    final success = await tProvider.saveTemplateToLibrary(_template!);
    if (success) {
      ToastService.success(l10n.addedToPersonalLibrary);
    }
  }

  void _showInstallDialog() {
    final l10n = AppLocalizations.of(context)!;
    final containers = context.read<ContainerProvider>().containers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.whereDoYouWantToInstall,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (containers.isEmpty)
              Text(l10n.noContainersCreateFirst)
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: containers.length,
                  itemBuilder: (c, i) => ListTile(
                    leading: const Icon(
                      Icons.inventory_2,
                      color: Colors.indigo,
                    ),
                    title: Text(containers[i].name),
                    onTap: () {
                      Navigator.pop(ctx);
                      _executeInstallation(containers[i]);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeInstallation(ContainerNode container) async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final tProvider = context.read<TemplateProvider>();
    final cProvider = context.read<ContainerProvider>();
    // Capture localizations and other values from the BuildContext
    // BEFORE any `await` to avoid using BuildContext across async gaps.
    final l10n = AppLocalizations.of(context)!;

    try {
      // 1. Optional: save to personal library
      await tProvider.saveTemplateToLibrary(_template!);

      // 2. Get the updated container to check existing lists
      final currentContainer = cProvider.containers.firstWhere(
        (c) => c.id == container.id,
        orElse: () => container,
      );

      List<CustomFieldDefinition> finalFields = [];

      // 3. Process each field from the template
      for (var field in _template!.fields) {
        // If the field is a dropdown and has defined options
        if (field.type == CustomFieldType.dropdown &&
            field.options != null &&
            field.options!.isNotEmpty) {
          final String listName = '${field.name} (${_template!.name})';

          // --- No-Duplicate Logic ---
          final existingList = currentContainer.dataLists.firstWhere(
            (l) => l.name == listName,
            orElse: () => ListData(id: -1, name: '', items: []),
          );

          int targetListId;

          if (existingList.id != -1) {
            // If the list already exists (from a previous installation), use its ID
            targetListId = existingList.id;
          } else {
            // If it doesn't exist, create it on the server
            final newList = await cProvider.createDataList(
              containerId: container.id,
              name: listName,
              description: l10n.autoGeneratedListFromTemplate,
              items: field.options!,
            );
            targetListId = newList.id;
          }

          // 🚩 AUTO ASSIGNMENT:
          // We inject the dataListId into the field as if the user had selected it
          finalFields.add(field.copyWith(dataListId: targetListId));
          } else {
            // Normal fields (text, number, etc.) are added unchanged
            finalFields.add(field);
          }
      }

      // 4. Create the real AssetType with fields already linked to lists
      await cProvider.addNewAssetTypeToContainer(
        containerId: container.id,
        name: _template!.name,
        fieldDefinitions: finalFields,
        isSerialized: true,
      );

      if (navigator.canPop()) navigator.pop();
      ToastService.success(l10n.installationSuccessAutoLists);
      router.go('/container/${container.id}/asset-types');
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      ToastService.error(l10n.errorInstallingTemplate(e.toString()));
    }
  }
}
