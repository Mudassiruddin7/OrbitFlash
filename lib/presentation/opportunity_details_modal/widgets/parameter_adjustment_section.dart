import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParameterAdjustmentSection extends StatelessWidget {
  final double selectedAmount;
  final double gasPriceGwei;
  final double slippageTolerance;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<double> onGasPriceChanged;
  final ValueChanged<double> onSlippageChanged;

  const ParameterAdjustmentSection({
    Key? key,
    required this.selectedAmount,
    required this.gasPriceGwei,
    required this.slippageTolerance,
    required this.onAmountChanged,
    required this.onGasPriceChanged,
    required this.onSlippageChanged,
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
              iconName: 'tune',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Parameter Adjustment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Parameters container
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
              // Amount slider
              _buildParameterSlider(
                context,
                icon: 'attach_money',
                label: 'Investment Amount',
                value: selectedAmount,
                min: 1000.0,
                max: 100000.0,
                divisions: 99,
                format: (value) => '\$${value.toStringAsFixed(0)}',
                onChanged: onAmountChanged,
                color: theme.colorScheme.primary,
              ),

              SizedBox(height: 4.h),

              // Gas price slider
              _buildParameterSlider(
                context,
                icon: 'local_gas_station',
                label: 'Gas Price',
                value: gasPriceGwei,
                min: 5.0,
                max: 100.0,
                divisions: 95,
                format: (value) => '${value.toStringAsFixed(0)} Gwei',
                onChanged: onGasPriceChanged,
                color: AppTheme.warningLight,
              ),

              SizedBox(height: 4.h),

              // Slippage tolerance slider
              _buildParameterSlider(
                context,
                icon: 'swap_horiz',
                label: 'Slippage Tolerance',
                value: slippageTolerance,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                format: (value) => '${value.toStringAsFixed(1)}%',
                onChanged: onSlippageChanged,
                color: theme.colorScheme.secondary,
                warning: slippageTolerance > 2.0
                    ? 'High slippage may result in unexpected losses'
                    : null,
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Real-time calculations
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calculate',
                    color: theme.colorScheme.tertiary,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Updated Calculations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expected Profit:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\$${_calculateProfit().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gas Cost:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\$${_calculateGasCost().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warningLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Divider(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Profit:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\$${(_calculateProfit() - _calculateGasCost()).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.tertiary,
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

  Widget _buildParameterSlider(
    BuildContext context, {
    required String icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
    required Color color,
    String? warning,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                format(value),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        if (warning != null) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning_amber',
                color: theme.colorScheme.error,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  double _calculateProfit() {
    // Simple profit calculation based on amount and base margin
    const baseProfitMargin = 8.75; // 8.75%
    return selectedAmount * (baseProfitMargin / 100);
  }

  double _calculateGasCost() {
    // Gas cost calculation based on gas price
    const baseGasUnits = 150000; // Typical flash loan gas usage
    const ethPrice = 2500.0; // Mock ETH price in USD
    return (baseGasUnits * gasPriceGwei * 1e-9) * ethPrice;
  }
}
