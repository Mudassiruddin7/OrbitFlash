import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FinancialMetricsSection extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const FinancialMetricsSection({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Financial Metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Metrics grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          children: [
            _buildMetricCard(
              context,
              icon: 'attach_money',
              label: 'Required Capital',
              value: '\$${opportunity['requiredCapital'] ?? '0.00'}',
              color: theme.colorScheme.primary,
            ),
            _buildMetricCard(
              context,
              icon: 'trending_up',
              label: 'Est. Profit',
              value: '\$${opportunity['estimatedProfit'] ?? '0.00'}',
              color: theme.colorScheme.tertiary,
            ),
            _buildMetricCard(
              context,
              icon: 'local_gas_station',
              label: 'Gas Fee',
              value: '\$${opportunity['gasFee'] ?? '0.00'}',
              color: AppTheme.warningLight,
            ),
            _buildMetricCard(
              context,
              icon: 'percent',
              label: 'APR',
              value: opportunity['apr'] ?? '0.0%',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Additional metrics
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context,
                icon: 'water_drop',
                label: 'Pool Liquidity',
                value: opportunity['poolLiquidity'] ?? 'N/A',
              ),
              Divider(
                height: 3.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildDetailRow(
                context,
                icon: 'bar_chart',
                label: '24h Volume',
                value: opportunity['volume24h'] ?? 'N/A',
              ),
              Divider(
                height: 3.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildDetailRow(
                context,
                icon: 'swap_horiz',
                label: 'Slippage Impact',
                value: opportunity['slippageImpact'] ?? 'N/A',
              ),
              Divider(
                height: 3.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildDetailRow(
                context,
                icon: 'schedule',
                label: 'Block Expiry',
                value: opportunity['blockExpiry'] ?? 'N/A',
                isHighlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: isHighlight
              ? AppTheme.warningLight
              : theme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isHighlight
                ? AppTheme.warningLight
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
