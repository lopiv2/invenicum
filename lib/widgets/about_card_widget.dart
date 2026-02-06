import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/services/toast_service.dart';

class AboutCardWidget extends StatelessWidget {
  const AboutCardWidget({super.key});

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
              onTap: () {
                ToastService.info('Invenicum v${Environment.appVersion}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
