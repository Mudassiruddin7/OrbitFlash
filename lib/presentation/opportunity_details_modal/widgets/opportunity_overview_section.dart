import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OpportunityOverviewSection extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityOverviewSection({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  Color _getRiskColor(String riskLevel, ColorScheme colorScheme) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return colorScheme.tertiary;
      case 'medium':
        return AppTheme.warningLight;
      case 'high':
        return colorScheme.error;
      default:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profitMargin = (opportunity['profitMargin'] as double?) ?? 0.0;
    final riskLevel = opportunity['riskLevel'] as String? ?? 'Medium';
    final isHighProfit = profitMargin > 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'info_outline',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Opportunity Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Overview card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighProfit
                  ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isHighProfit ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: isHighProfit ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token pair and protocol
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity['tokenPair'] ?? 'Unknown Pair',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'account_balance',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              opportunity['protocol'] ?? 'Unknown Protocol',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Profit margin
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${profitMargin.toStringAsFixed(2)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Profit Margin',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Tags and indicators
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  // Risk level tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getRiskColor(riskLevel, theme.colorScheme)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRiskColor(riskLevel, theme.colorScheme)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: riskLevel.toLowerCase() == 'low'
                              ? 'shield'
                              : riskLevel.toLowerCase() == 'high'
                                  ? 'warning'
                                  : 'info',
                          color: _getRiskColor(riskLevel, theme.colorScheme),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '$riskLevel Risk',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getRiskColor(riskLevel, theme.colorScheme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // High profit tag
                  if (isHighProfit)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              theme.colorScheme.tertiary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.tertiary,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'High Profit',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Liquidity depth tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'water_drop',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${opportunity['liquidityDepth'] ?? 'Medium'} Liquidity',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
