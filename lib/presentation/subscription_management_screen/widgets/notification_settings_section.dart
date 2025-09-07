import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsSection extends StatefulWidget {
  final Map<String, bool> notificationSettings;
  final Function(String, bool) onSettingChanged;
  final VoidCallback onTestNotification;

  const NotificationSettingsSection({
    Key? key,
    required this.notificationSettings,
    required this.onSettingChanged,
    required this.onTestNotification,
  }) : super(key: key);

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  bool _isTestingNotification = false;

  Future<void> _handleTestNotification() async {
    setState(() {
      _isTestingNotification = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    widget.onTestNotification();

    setState(() {
      _isTestingNotification = false;
    });
  }

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
                  iconName: 'notifications',
                  color: isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    "Push Notifications",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...widget.notificationSettings.entries.map(
              (entry) => _buildNotificationToggle(
                context,
                entry.key,
                entry.value,
                isLight,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:
                    _isTestingNotification ? null : _handleTestNotification,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  side: BorderSide(
                    color:
                        isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isTestingNotification
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLight
                                ? AppTheme.primaryLight
                                : AppTheme.primaryDark,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'send',
                            color: isLight
                                ? AppTheme.primaryLight
                                : AppTheme.primaryDark,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Test Notification",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: isLight
                                      ? AppTheme.primaryLight
                                      : AppTheme.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String key,
    bool value,
    bool isLight,
  ) {
    final Map<String, String> settingLabels = {
      'opportunityAlerts': 'Opportunity Alerts',
      'executionUpdates': 'Execution Updates',
      'systemStatus': 'System Status',
      'priceAlerts': 'Price Alerts',
      'marketUpdates': 'Market Updates',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              settingLabels[key] ?? key,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isLight
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textPrimaryDark,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              widget.onSettingChanged(key, newValue);
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
      ),
    );
  }
}
