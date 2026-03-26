import 'package:flutter/material.dart';

class IntegrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final bool isLinked;
  final VoidCallback onTap;
  final Widget? bottomWidget;

  const IntegrationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLinked,
    required this.onTap,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(child: icon),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                subtitle, 
                style: const TextStyle(fontSize: 13)
              ),
              trailing: isLinked
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    )
                  : const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: onTap,
            ),
            if (bottomWidget != null)
              Padding(
                padding: const EdgeInsets.only(left: 72, bottom: 12, right: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: bottomWidget,
                ),
              ),
          ],
        ),
      ),
    );
  }
}