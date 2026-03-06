import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../widgets/ui/price_display_widget.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class TotalSpendingWidget extends StatelessWidget {
  final double amount;
  final bool isLoading;

  const TotalSpendingWidget({
    super.key,
    required this.amount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: .12),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade900.withValues(alpha: .95),
                  Colors.green.shade700.withValues(alpha: .85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Detalle geométrico moderno (Líneas de red sutiles)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: .05),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBadge(l10n),
                        Icon(
                          Icons.security_rounded,
                          color: Colors.white.withValues(alpha: .4),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.totalSpending,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .65),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isLoading)
                      _buildShimmerLoader()
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: PriceDisplayWidget(
                          value: amount,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildFooterInfo(l10n),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(AppLocalizations l10) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.history_edu_rounded, color: Colors.greenAccent, size: 14),
          SizedBox(width: 6),
          Text(
            l10.adquisition,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(AppLocalizations l10) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.white.withValues(alpha: .4),
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10.baseCostAccumulatedWithoutInflation,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .4),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 30,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
