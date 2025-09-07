import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RiskAssessmentSection extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const RiskAssessmentSection({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final executionProbability =
        (opportunity['executionProbability'] as double?) ?? 0.0;
    final riskLevel = opportunity['riskLevel'] as String? ?? 'Medium';
    final smartContractRisk =
        opportunity['smartContractRisk'] as String? ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'security',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Risk Assessment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Risk meters
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
              // Execution probability
              _buildRiskMeter(
                context,
                label: 'Execution Probability',
                value: executionProbability,
                color: executionProbability > 0.8
                    ? theme.colorScheme.tertiary
                    : executionProbability > 0.6
                        ? AppTheme.warningLight
                        : theme.colorScheme.error,
                percentage: '${(executionProbability * 100).toInt()}%',
              ),

              SizedBox(height: 3.h),

              // Overall risk level
              _buildRiskMeter(
                context,
                label: 'Overall Risk Level',
                value: _getRiskValue(riskLevel),
                color: _getRiskColor(riskLevel, theme.colorScheme),
                percentage: riskLevel.toUpperCase(),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Risk factors
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'verified_user',
                    color: smartContractRisk.toLowerCase() == 'verified'
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Smart Contract: $smartContractRisk',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: smartContractRisk.toLowerCase() == 'verified'
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              Text(
                'Risk Factors:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 1.h),

              // Risk factors list
              ..._buildRiskFactors(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskMeter(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required String percentage,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              percentage,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        // Progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRiskFactors(BuildContext context) {
    final theme = Theme.of(context);
    final riskFactors = opportunity['riskFactors'] as List<String>? ?? [];

    if (riskFactors.isEmpty) {
      return [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.tertiary,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'No significant risk factors identified',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return riskFactors.map((factor) {
      return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconWidget(
              iconName: 'warning_amber',
              color: AppTheme.warningLight,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                factor,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  double _getRiskValue(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 0.3;
      case 'medium':
        return 0.6;
      case 'high':
        return 0.9;
      default:
        return 0.5;
    }
  }

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
}
