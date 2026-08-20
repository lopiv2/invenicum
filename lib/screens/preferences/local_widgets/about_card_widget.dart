import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class _VersionCheckResult {
  final String? latestVersion;
  final bool hasUpdate;
  final bool hasError;
  final String? releasesUrl;

  const _VersionCheckResult({
    required this.latestVersion,
    required this.hasUpdate,
    required this.hasError,
    this.releasesUrl,
  });
}

class AboutCardWidget extends StatelessWidget {
  const AboutCardWidget({super.key});

  static const String _fallbackGithubReleasesUrl =
      'https://github.com/lopiv2/invenicum/releases';

  /// Devuelve 1 si a > b, -1 si a < b, 0 si son iguales.
  /// Entiende prereleases: 1.1.0 > 1.1.0-beta.1 > 1.0.2
  int _compareSemver(String a, String b) {
    final aClean = a.trim().replaceFirst(RegExp(r'^v'), '');
    final bClean = b.trim().replaceFirst(RegExp(r'^v'), '');

    final aParts = aClean.split('-');
    final bParts = bClean.split('-');

    final aBase = aParts[0]
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final bBase = bParts[0]
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    while (aBase.length < 3) aBase.add(0);
    while (bBase.length < 3) bBase.add(0);

    for (int i = 0; i < 3; i++) {
      if (aBase[i] > bBase[i]) return 1;
      if (aBase[i] < bBase[i]) return -1;
    }

    // Misma base: prerelease es MENOR que release estable
    final aIsPrerelease = aParts.length > 1;
    final bIsPrerelease = bParts.length > 1;

    if (aIsPrerelease && !bIsPrerelease) return -1;
    if (!aIsPrerelease && bIsPrerelease) return 1;
    return 0;
  }

  String _sanitizeVersion(String raw) {
    // Solo quitar la v inicial y espacios, mantener prerelease completo
    return raw.trim().replaceFirst(RegExp(r'^v'), '');
  }

  Future<_VersionCheckResult> _checkLatestVersion(BuildContext context) async {
    try {
      final api = context.read<ApiService>();
      final payload = await api.checkAppVersion(
        currentVersion: Environment.appVersion,
      );

      final latest = _sanitizeVersion(
        (payload['latestVersion'] ?? payload['latest'] ?? '').toString(),
      );
      final local = _sanitizeVersion(Environment.appVersion);
      final hasUpdate = _compareSemver(latest, local) > 0;
      final releasesUrl = payload['releasesUrl']?.toString();

      return _VersionCheckResult(
        latestVersion: latest,
        hasUpdate: hasUpdate,
        hasError: false,
        releasesUrl: releasesUrl,
      );
    } catch (_) {
      return const _VersionCheckResult(
        latestVersion: null,
        hasUpdate: false,
        hasError: true,
      );
    }
  }

  Future<void> _openReleases(String? releaseUrl) async {
    final uri = Uri.parse(releaseUrl ?? _fallbackGithubReleasesUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final future = _checkLatestVersion(context);

    showAppDialog<void>(
      context: context,
      title: l10n.aboutDialogTitle,
      body: StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return SizedBox(
            width: 430,
            child: FutureBuilder<_VersionCheckResult>(
              future: future,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final data = snapshot.data;

                final latestVersionRaw = data?.latestVersion;
                final latestVersion = latestVersionRaw != null
                    ? 'v$latestVersionRaw'
                    : l10n.aboutVersionUnknown;

                String versionStateText;
                Color stateColor;
                IconData stateIcon;

                if (isLoading) {
                  versionStateText = l10n.aboutCheckingVersion;
                  stateColor = theme.colorScheme.primary;
                  stateIcon = Icons.sync;
                } else if (data?.hasError == true) {
                  versionStateText = l10n.aboutVersionCheckFailed;
                  stateColor = theme.colorScheme.error;
                  stateIcon = Icons.error_outline;
                } else if (data?.hasUpdate == true) {
                  versionStateText = l10n.aboutUpdateAvailable;
                  stateColor = theme.colorScheme.tertiary;
                  stateIcon = Icons.upgrade;
                } else {
                  versionStateText = l10n.aboutVersionUpToDate;
                  stateColor = Colors.green.shade700;
                  stateIcon = Icons.verified_rounded;
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutDialogCoolText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (data?.hasUpdate == true)
                            ? theme.colorScheme.error.withValues(alpha: 0.12)
                            : theme.colorScheme.onInverseSurface.withValues(
                                alpha: 0.55,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.aboutCurrentVersionLabel}: v${Environment.appVersion}',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${l10n.aboutLatestVersionLabel}: $latestVersion',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (isLoading)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: AppLoadingIndicator(
                                    strokeWidth: 2,
                                    color: stateColor,
                                  ),
                                )
                              else
                                Icon(stateIcon, size: 16, color: stateColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  versionStateText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: stateColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.closeLabel),
        ),
        FilledButton.tonalIcon(
          onPressed: () => _openReleases(null),
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.aboutOpenReleases),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutInvenicum,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.aboutInvenicum),
              subtitle: Text(
                AppLocalizations.of(context)!.version(Environment.appVersion),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
