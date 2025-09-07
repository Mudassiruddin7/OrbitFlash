import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ModalActionsSection extends StatelessWidget {
  final bool isOperator;
  final VoidCallback onExecute;
  final VoidCallback onAddToWatchlist;
  final Map<String, dynamic> opportunity;

  const ModalActionsSection({
    Key? key,
    required this.isOperator,
    required this.onExecute,
    required this.onAddToWatchlist,
    required this.opportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          if (isOperator) ...[
            // Execute button (primary action)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onExecute,
                icon: CustomIconWidget(
                  iconName: 'rocket_launch',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Execute Request',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Watchlist button (secondary action)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddToWatchlist,
                icon: CustomIconWidget(
                  iconName: 'bookmark_add',
                  color: theme.colorScheme.secondary,
                  size: 18,
                ),
                label: Text(
                  'Watchlist',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Observer mode - only watchlist and analysis actions
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAddToWatchlist,
                icon: CustomIconWidget(
                  iconName: 'bookmark_add',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Add to Watchlist',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor:
                      theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Detailed analysis button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDetailedAnalysis(context),
                icon: CustomIconWidget(
                  iconName: 'analytics',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  'Analysis',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetailedAnalysis(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'analytics',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Detailed Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Analysis content
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Conditions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Current market volatility and liquidity conditions suggest this opportunity has a ${(opportunity['executionProbability'] * 100).toInt()}% probability of successful execution.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Risk Assessment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'This ${opportunity['riskLevel']?.toString().toLowerCase() ?? 'medium'} risk opportunity requires careful monitoring. Consider market conditions and portfolio exposure.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
