import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConfirmationDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> opportunity;
  final String amount;
  final String slippage;
  final String gasPrice;

  const ConfirmationDetailsWidget({
    Key? key,
    required this.opportunity,
    required this.amount,
    required this.slippage,
    required this.gasPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final estimatedGasCost = _calculateGasCost();
    final netProfit = _calculateNetProfit(estimatedGasCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Summary',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                  'Protocol', opportunity['protocol'] ?? 'Uniswap V3'),
              _buildDetailRow(
                  'Token Pair', opportunity['tokenPair'] ?? 'ETH/USDC'),
              _buildDetailRow('Amount', '\$$amount'),
              _buildDetailRow('Slippage Tolerance', '$slippage%'),
              _buildDetailRow('Gas Price', '$gasPrice Gwei'),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                'Estimated Profit',
                '\$${opportunity['profitEstimate'] ?? '1,245.67'}',
                valueColor: AppTheme.successLight,
              ),
              _buildDetailRow(
                'Estimated Gas Cost',
                '\$$estimatedGasCost',
                valueColor: AppTheme.warningLight,
              ),
              Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                height: 2.h,
              ),
              _buildDetailRow(
                'Net Profit',
                '\$$netProfit',
                valueColor: double.parse(netProfit) > 0
                    ? AppTheme.successLight
                    : AppTheme.errorLight,
                isHighlighted: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.warningLight.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.warningLight.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Risk Warnings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                '• Flash loan execution is irreversible once submitted\n'
                '• Market conditions may change during execution\n'
                '• Gas price fluctuations may affect profitability\n'
                '• Network congestion may cause transaction failure',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateGasCost() {
    final gasPrice = double.tryParse(this.gasPrice) ?? 25.0;
    final estimatedGasUnits = 150000; // Typical flash loan gas usage
    final ethPrice = 2500.0; // Mock ETH price
    final gasCostEth = (gasPrice * estimatedGasUnits) / 1e9;
    final gasCostUsd = gasCostEth * ethPrice;
    return gasCostUsd.toStringAsFixed(2);
  }

  String _calculateNetProfit(String gasCost) {
    final profit = double.tryParse(
            opportunity['profitEstimate']?.toString().replaceAll(',', '') ??
                '1245.67') ??
        1245.67;
    final cost = double.tryParse(gasCost) ?? 0.0;
    final net = profit - cost;
    return net.toStringAsFixed(2);
  }
}
