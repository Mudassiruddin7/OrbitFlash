import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistoricalPerformanceSection extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const HistoricalPerformanceSection({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successRate = (opportunity['successRate'] as double?) ?? 0.0;
    final historicalData = opportunity['historicalData'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'show_chart',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Historical Performance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Success rate card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(51), // alpha: 0.2 * 255
            ),
          ),
          child: Row(
            children: [
              // Success rate indicator
              Container(
                width: 20.w,
                height: 20.w,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.tertiary.withAlpha(25),
                      ),
                    ),

                    // Progress circle
                    CircularProgressIndicator(
                      value: successRate,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.tertiary.withAlpha(51),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.tertiary,
                      ),
                    ),

                    // Center text
                    Center(
                      child: Text(
                        '${(successRate * 100).toInt()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // Success rate details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Rate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Similar opportunities with this protocol and token pair',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: successRate > 0.8 ? 'trending_up' : 'trending_flat',
                          color: successRate > 0.8
                              ? theme.colorScheme.tertiary
                              : AppTheme.warningLight,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          successRate > 0.8
                              ? 'High Success Rate'
                              : 'Moderate Success Rate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: successRate > 0.8
                                ? theme.colorScheme.tertiary
                                : AppTheme.warningLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Chart container
        if (historicalData.isNotEmpty)
          Container(
            width: double.infinity,
            height: 30.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(51),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profit Trends (Last 7 Periods)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: LineChart(
                    _buildChartData(theme),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  LineChartData _buildChartData(ThemeData theme) {
    final historicalData = opportunity['historicalData'] as List<dynamic>? ?? [];

    if (historicalData.isEmpty) {
      return LineChartData();
    }

    final spots = historicalData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final profit = (data['profit'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), profit);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withAlpha(25),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 2,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < historicalData.length) {
                final data = historicalData[index] as Map<String, dynamic>;
                final time = data['time'] as String? ?? '';
                return Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.tertiary,
              theme.colorScheme.tertiary.withAlpha(204),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: theme.colorScheme.tertiary,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.tertiary.withAlpha(51),
                theme.colorScheme.tertiary.withAlpha(13),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding: const EdgeInsets.all(8),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)}%',
                theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
