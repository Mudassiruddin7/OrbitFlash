import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_preferences_section.dart';
import './widgets/notification_settings_section.dart';
import './widgets/subscription_tier_card.dart';
import './widgets/threshold_settings_section.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  String _currentTier = 'basic';
  bool _isLoading = false;

  // Mock subscription tiers data
  final List<Map<String, dynamic>> _subscriptionTiers = [
    {
      "id": "basic",
      "name": "Basic",
      "price": "Free",
      "description":
          "Essential flash loan monitoring with basic alerts and limited opportunities.",
      "features": [
        "Up to 10 opportunities per day",
        "Basic push notifications",
        "Standard data refresh rate",
        "Community support",
      ],
    },
    {
      "id": "pro",
      "name": "Pro",
      "price": "\$29/month",
      "description":
          "Advanced monitoring with real-time alerts, unlimited opportunities, and priority support.",
      "features": [
        "Unlimited opportunities",
        "Real-time push notifications",
        "Advanced threshold controls",
        "Priority customer support",
        "Custom alert frequencies",
        "WebSocket connection optimization",
      ],
    },
    {
      "id": "enterprise",
      "name": "Enterprise",
      "price": "\$99/month",
      "description":
          "Complete DeFi trading suite with premium features, analytics, and dedicated support.",
      "features": [
        "All Pro features included",
        "Advanced analytics dashboard",
        "Custom API access",
        "Dedicated account manager",
        "White-label options",
        "Priority execution queue",
        "Advanced risk management",
      ],
    },
  ];

  // Mock notification settings
  Map<String, bool> _notificationSettings = {
    'opportunityAlerts': true,
    'executionUpdates': true,
    'systemStatus': false,
    'priceAlerts': true,
    'marketUpdates': false,
  };

  // Mock threshold settings
  Map<String, double> _thresholdSettings = {
    'profitMinimum': 100.0,
    'opportunityThreshold': 2.5,
    'alertFrequency': 5.0,
  };

  // Mock connection preferences
  Map<String, dynamic> _connectionSettings = {
    'bandwidthMode': 'auto',
    'autoReconnect': true,
    'dataSaver': false,
  };

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? AppTheme.backgroundLight : AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(
          "Subscription Management",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isLight ? AppTheme.textPrimaryLight : AppTheme.textPrimaryDark,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshSettings,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: isLight
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textPrimaryDark,
                    size: 24,
                  ),
          ),
        ],
        backgroundColor: isLight ? AppTheme.surfaceLight : AppTheme.surfaceDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildCurrentTierHeader(context, isLight),
                  SizedBox(height: 2.h),
                  _buildSubscriptionTiers(context),
                  SizedBox(height: 3.h),
                  NotificationSettingsSection(
                    notificationSettings: _notificationSettings,
                    onSettingChanged: _handleNotificationSettingChanged,
                    onTestNotification: _handleTestNotification,
                  ),
                  SizedBox(height: 2.h),
                  ThresholdSettingsSection(
                    thresholdSettings: _thresholdSettings,
                    onThresholdChanged: _handleThresholdChanged,
                  ),
                  SizedBox(height: 2.h),
                  ConnectionPreferencesSection(
                    connectionSettings: _connectionSettings,
                    onSettingChanged: _handleConnectionSettingChanged,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentTierHeader(BuildContext context, bool isLight) {
    final currentTierData = _subscriptionTiers.firstWhere(
      (tier) => tier['id'] == _currentTier,
      orElse: () => _subscriptionTiers[0],
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
            (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                .withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'star',
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Plan",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  "${currentTierData['name']} - ${currentTierData['price']}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTiers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "Available Plans",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: 1.h),
        ..._subscriptionTiers.map((tier) => SubscriptionTierCard(
              tierData: tier,
              isCurrentTier: tier['id'] == _currentTier,
              onUpgrade: tier['id'] != _currentTier
                  ? () => _handleUpgrade(tier['id'] as String)
                  : null,
            )),
      ],
    );
  }

  Future<void> _refreshSettings() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
      msg: "Settings refreshed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
    );
  }

  void _handleNotificationSettingChanged(String key, bool value) {
    setState(() {
      _notificationSettings[key] = value;
    });

    // Simulate API call
    _saveSettings();
  }

  void _handleThresholdChanged(String key, double value) {
    setState(() {
      _thresholdSettings[key] = value;
    });

    // Simulate API call with debouncing
    _saveSettings();
  }

  void _handleConnectionSettingChanged(String key, dynamic value) {
    setState(() {
      _connectionSettings[key] = value;
    });

    // Simulate API call
    _saveSettings();
  }

  void _handleTestNotification() {
    Fluttertoast.showToast(
      msg: "Test notification sent! Check your device notifications.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryLight,
      textColor: Colors.white,
    );
  }

  void _handleUpgrade(String tierId) {
    showDialog(
      context: context,
      builder: (context) => _buildUpgradeDialog(context, tierId),
    );
  }

  Widget _buildUpgradeDialog(BuildContext context, String tierId) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final tierData =
        _subscriptionTiers.firstWhere((tier) => tier['id'] == tierId);

    return AlertDialog(
      backgroundColor: isLight ? AppTheme.surfaceLight : AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        "Upgrade to ${tierData['name']}",
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You're about to upgrade to the ${tierData['name']} plan for ${tierData['price']}.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 2.h),
          Text(
            "This will unlock:",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),
          ...((tierData['features'] as List).take(3).map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check',
                      color: isLight
                          ? AppTheme.successLight
                          : AppTheme.successDark,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        feature as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: isLight
                  ? AppTheme.textSecondaryLight
                  : AppTheme.textSecondaryDark,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _processUpgrade(tierId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
            foregroundColor: Colors.white,
          ),
          child: const Text("Upgrade Now"),
        ),
      ],
    );
  }

  void _processUpgrade(String tierId) {
    setState(() {
      _currentTier = tierId;
    });

    Fluttertoast.showToast(
      msg: "Successfully upgraded! Welcome to your new plan.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
    );
  }

  Future<void> _saveSettings() async {
    // Simulate API call to save settings
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
