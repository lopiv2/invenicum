import 'package:invenicum/core/routing/navigator_key.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Localizations for layers without a [BuildContext] (services, providers).
///
/// Resolves from the global navigator key. Null only when the app tree
/// is not built yet — in which case toasts could not be displayed anyway.
AppLocalizations? serviceL10n() {
  final context = rootNavigatorKey.currentContext;
  return context == null ? null : AppLocalizations.of(context);
}
