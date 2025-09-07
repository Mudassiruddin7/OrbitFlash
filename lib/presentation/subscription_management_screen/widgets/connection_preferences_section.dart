import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionPreferencesSection extends StatefulWidget {
  final Map<String, dynamic> connectionSettings;
  final Function(String, dynamic) onSettingChanged;

  const ConnectionPreferencesSection({
    Key? key,
    required this.connectionSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<ConnectionPreferencesSection> createState() =>
      _ConnectionPreferencesSectionState();
}

class _ConnectionPreferencesSectionState
    extends State<ConnectionPreferencesSection> {
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
                  iconName: 'wifi',
                  color: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    "Connection Preferences",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildBandwidthSelector(context, isLight),
            SizedBox(height: 2.h),
            _buildAutoReconnectToggle(context, isLight),
            SizedBox(height: 2.h),
            _buildDataSaverToggle(context, isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildBandwidthSelector(BuildContext context, bool isLight) {
    final String currentBandwidth =
        widget.connectionSettings['bandwidthMode'] as String? ?? 'auto';
    final List<Map<String, String>> bandwidthOptions = [
      {
        'value': 'low',
        'label': 'Low Bandwidth',
        'description': 'Reduced data usage'
      },
      {
        'value': 'auto',
        'label': 'Auto',
        'description': 'Optimized for connection'
      },
      {
        'value': 'high',
        'label': 'High Quality',
        'description': 'Maximum data quality'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bandwidth Mode",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isLight
                    ? AppTheme.textPrimaryLight
                    : AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 1.h),
        ...bandwidthOptions.map(
          (option) => RadioListTile<String>(
            value: option['value']!,
            groupValue: currentBandwidth,
            onChanged: (value) {
              if (value != null) {
                widget.onSettingChanged('bandwidthMode', value);
              }
            },
            title: Text(
              option['label']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isLight
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textPrimaryDark,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              option['description']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isLight
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            activeColor: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoReconnectToggle(BuildContext context, bool isLight) {
    final bool autoReconnect =
        widget.connectionSettings['autoReconnect'] as bool? ?? true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Auto Reconnect",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLight
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Automatically reconnect when connection is lost",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLight
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Switch(
          value: autoReconnect,
          onChanged: (value) {
            widget.onSettingChanged('autoReconnect', value);
          },
          activeColor: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
          activeTrackColor:
              (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                  .withValues(alpha: 0.3),
          inactiveThumbColor:
              isLight ? AppTheme.secondaryLight : AppTheme.secondaryDark,
          inactiveTrackColor:
              (isLight ? AppTheme.secondaryLight : AppTheme.secondaryDark)
                  .withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildDataSaverToggle(BuildContext context, bool isLight) {
    final bool dataSaver =
        widget.connectionSettings['dataSaver'] as bool? ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data Saver Mode",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLight
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Reduce data usage on mobile networks",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLight
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Switch(
          value: dataSaver,
          onChanged: (value) {
            widget.onSettingChanged('dataSaver', value);
          },
          activeColor: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
          activeTrackColor:
              (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                  .withValues(alpha: 0.3),
          inactiveThumbColor:
              isLight ? AppTheme.secondaryLight : AppTheme.secondaryDark,
          inactiveTrackColor:
              (isLight ? AppTheme.secondaryLight : AppTheme.secondaryDark)
                  .withValues(alpha: 0.2),
        ),
      ],
    );
  }
}
