import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class LoanManagementCardWidget extends StatelessWidget {
  const LoanManagementCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.loanManagement,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.deliveryVoucherEditor),
              subtitle: Text(AppLocalizations.of(context)!.customizeDeliveryVoucher),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                context.pushNamed(RouteNames.voucherEditor);
              },
            ),
          ],
        ),
      ),
    );
  }
}
