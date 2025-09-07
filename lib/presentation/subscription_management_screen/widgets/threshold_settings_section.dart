import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThresholdSettingsSection extends StatefulWidget {
  final Map<String, double> thresholdSettings;
  final Function(String, double) onThresholdChanged;

  const ThresholdSettingsSection({
    Key? key,
    required this.thresholdSettings,
    required this.onThresholdChanged,
  }) : super(key: key);

  @override
  State<ThresholdSettingsSection> createState() =>
      _ThresholdSettingsSectionState();
}

class _ThresholdSettingsSectionState extends State<ThresholdSettingsSection> {
  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLight ? AppTheme.surfaceLight : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppTheme.borderLight : AppTheme.borderDark,
        ),
        boxShadow: [
          BoxShadow(
            color: isLight ? AppTheme.shadowLight : AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'tune',
                  color: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    "Alert Thresholds",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...widget.thresholdSettings.entries.map(
              (entry) => _buildThresholdSlider(
                context,
                entry.key,
                entry.value,
                isLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSlider(
    BuildContext context,
    String key,
    double value,
    bool isLight,
  ) {
    final Map<String, Map<String, dynamic>> thresholdConfig = {
      'profitMinimum': {
        'label': 'Minimum Profit (\$)',
        'min': 0.0,
        'max': 1000.0,
        'divisions': 100,
        'format': (double val) => '\$${val.toStringAsFixed(0)}',
      },
      'opportunityThreshold': {
        'label': 'Opportunity Threshold (%)',
        'min': 0.0,
        'max': 10.0,
        'divisions': 100,
        'format': (double val) => '${val.toStringAsFixed(1)}%',
      },
      'alertFrequency': {
        'label': 'Alert Frequency (minutes)',
        'min': 1.0,
        'max': 60.0,
        'divisions': 59,
        'format': (double val) => '${val.toStringAsFixed(0)} min',
      },
    };

    final config = thresholdConfig[key];
    if (config == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  config['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isLight
                            ? AppTheme.textPrimaryLight
                            : AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color:
                      (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (config['format'] as Function)(value),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isLight
                            ? AppTheme.primaryLight
                            : AppTheme.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:
                  isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
              inactiveTrackColor:
                  (isLight ? AppTheme.secondaryLight : AppTheme.secondaryDark)
                      .withValues(alpha: 0.3),
              thumbColor:
                  isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
              overlayColor:
                  (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                      .withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: config['min'] as double,
              max: config['max'] as double,
              divisions: config['divisions'] as int,
              onChanged: (newValue) {
                setState(() {
                  widget.onThresholdChanged(key, newValue);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
