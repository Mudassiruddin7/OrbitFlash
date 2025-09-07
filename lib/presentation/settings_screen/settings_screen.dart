import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/biometric_settings_widget.dart';
import './widgets/developer_options_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/theme_selector_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isPushNotifications = true;
  bool _isEmailNotifications = false;
  bool _isBiometricEnabled = true;
  bool _isAutoLock = true;
  bool _isDebugMode = false;
  bool _isMockData = false;
  String _selectedTheme = 'Auto';
  String _walletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96590e4CAF';
  String _connectionStatus = 'Connected';
  int _sessionTimeout = 15; // minutes
  String _apiEndpoint = 'https://api.orbitflash.io/v1';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isPushNotifications = prefs.getBool('isPushNotifications') ?? true;
      _isEmailNotifications = prefs.getBool('isEmailNotifications') ?? false;
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? true;
      _isAutoLock = prefs.getBool('isAutoLock') ?? true;
      _isDebugMode = prefs.getBool('isDebugMode') ?? false;
      _isMockData = prefs.getBool('isMockData') ?? false;
      _selectedTheme = prefs.getString('selectedTheme') ?? 'Auto';
      _sessionTimeout = prefs.getInt('sessionTimeout') ?? 15;
      _apiEndpoint =
          prefs.getString('apiEndpoint') ?? 'https://api.orbitflash.io/v1';
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setBool('isPushNotifications', _isPushNotifications);
      await prefs.setBool('isEmailNotifications', _isEmailNotifications);
      await prefs.setBool('isBiometricEnabled', _isBiometricEnabled);
      await prefs.setBool('isAutoLock', _isAutoLock);
      await prefs.setBool('isDebugMode', _isDebugMode);
      await prefs.setBool('isMockData', _isMockData);
      await prefs.setString('selectedTheme', _selectedTheme);
      await prefs.setInt('sessionTimeout', _sessionTimeout);
      await prefs.setString('apiEndpoint', _apiEndpoint);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          children: [
            ProfileHeaderWidget(
              walletAddress: _walletAddress,
              connectionStatus: _connectionStatus,
              onWalletTap: _handleWalletSettings,
            ),
            SizedBox(height: 3.h),

            // Account Management Section
            SettingsSectionWidget(
              title: 'Account Management',
              icon: 'account_circle',
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'account_balance_wallet',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Wallet Connection',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    _connectionStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _connectionStatus == 'Connected'
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleWalletSettings,
                ),
                BiometricSettingsWidget(
                  isBiometricEnabled: _isBiometricEnabled,
                  onChanged: (value) {
                    setState(() => _isBiometricEnabled = value);
                    _saveSettings();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'lock_clock',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Auto-Lock',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Lock app after $_sessionTimeout minutes of inactivity',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: _isAutoLock,
                    onChanged: (value) {
                      setState(() => _isAutoLock = value);
                      _saveSettings();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Notification Preferences Section
            SettingsSectionWidget(
              title: 'Notification Preferences',
              icon: 'notifications',
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'notifications_active',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Push Notifications',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Receive alerts for new opportunities',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: _isPushNotifications,
                    onChanged: (value) {
                      setState(() => _isPushNotifications = value);
                      _saveSettings();
                    },
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'email',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Email Notifications',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Daily summary and important updates',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: _isEmailNotifications,
                    onChanged: (value) {
                      setState(() => _isEmailNotifications = value);
                      _saveSettings();
                    },
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'tune',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Notification Frequency',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Customize notification timing',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleNotificationFrequency,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Display Options Section
            SettingsSectionWidget(
              title: 'Display Options',
              icon: 'palette',
              children: [
                ThemeSelectorWidget(
                  selectedTheme: _selectedTheme,
                  onThemeChanged: (theme) {
                    setState(() => _selectedTheme = theme);
                    _saveSettings();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'bar_chart',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Chart Preferences',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Customize chart display settings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleChartPreferences,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'refresh',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Data Refresh Interval',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Automatically refresh every 30 seconds',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleDataRefreshSettings,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Security Settings Section
            SettingsSectionWidget(
              title: 'Security Settings',
              icon: 'security',
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'schedule',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Session Timeout',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    '$_sessionTimeout minutes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleSessionTimeoutSettings,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'privacy_tip',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Privacy Controls',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Manage data privacy settings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handlePrivacyControls,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Developer Options Section (for operators)
            DeveloperOptionsWidget(
              isDebugMode: _isDebugMode,
              isMockData: _isMockData,
              apiEndpoint: _apiEndpoint,
              onDebugModeChanged: (value) {
                setState(() => _isDebugMode = value);
                _saveSettings();
              },
              onMockDataChanged: (value) {
                setState(() => _isMockData = value);
                _saveSettings();
              },
              onApiEndpointChanged: (endpoint) {
                setState(() => _apiEndpoint = endpoint);
                _saveSettings();
              },
            ),
            SizedBox(height: 2.h),

            // App Information Section
            SettingsSectionWidget(
              title: 'App Information',
              icon: 'info',
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'info_outline',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Version',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    '1.0.0 (Build 2025009062)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'article',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Terms of Service',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'open_in_new',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleTermsOfService,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'shield',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'open_in_new',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handlePrivacyPolicy,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'support',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Support',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'open_in_new',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _handleSupport,
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _handleWalletSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Wallet Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('View Wallet Details'),
              onTap: () {
                Navigator.pop(context);
                _showWalletDetails();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'swap_horiz',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Switch Wallet'),
              onTap: () {
                Navigator.pop(context);
                _handleSwitchWallet();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Disconnect Wallet',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleDisconnectWallet();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showWalletDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Wallet Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _walletAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Status: $_connectionStatus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleSwitchWallet() {
    // Navigate to authentication screen
    Navigator.pushNamed(context, '/authentication-screen');
  }

  void _handleDisconnectWallet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Disconnect Wallet'),
        content: Text('Are you sure you want to disconnect your wallet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _connectionStatus = 'Disconnected';
                _walletAddress = '';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wallet disconnected'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Disconnect',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationFrequency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Notification Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose how often you want to receive notifications:'),
            SizedBox(height: 2.h),
            RadioListTile<String>(
              title: Text('Instant'),
              value: 'instant',
              groupValue: 'instant',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Every 5 minutes'),
              value: '5min',
              groupValue: 'instant',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Every 15 minutes'),
              value: '15min',
              groupValue: 'instant',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Hourly'),
              value: 'hourly',
              groupValue: 'instant',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleChartPreferences() {
    // Navigate to chart preferences
    _showComingSoonDialog('Chart Preferences');
  }

  void _handleDataRefreshSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Data Refresh Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select automatic refresh interval:'),
            SizedBox(height: 2.h),
            RadioListTile<String>(
              title: Text('10 seconds'),
              value: '10s',
              groupValue: '30s',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('30 seconds'),
              value: '30s',
              groupValue: '30s',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('1 minute'),
              value: '1min',
              groupValue: '30s',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Manual only'),
              value: 'manual',
              groupValue: '30s',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleSessionTimeoutSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Session Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Auto-lock after inactivity:'),
            SizedBox(height: 2.h),
            RadioListTile<int>(
              title: Text('5 minutes'),
              value: 5,
              groupValue: _sessionTimeout,
              onChanged: (value) {
                setState(() => _sessionTimeout = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: Text('15 minutes'),
              value: 15,
              groupValue: _sessionTimeout,
              onChanged: (value) {
                setState(() => _sessionTimeout = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: Text('30 minutes'),
              value: 30,
              groupValue: _sessionTimeout,
              onChanged: (value) {
                setState(() => _sessionTimeout = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: Text('Never'),
              value: 0,
              groupValue: _sessionTimeout,
              onChanged: (value) {
                setState(() => _sessionTimeout = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyControls() {
    _showComingSoonDialog('Privacy Controls');
  }

  void _handleTermsOfService() {
    _showComingSoonDialog('Terms of Service');
  }

  void _handlePrivacyPolicy() {
    _showComingSoonDialog('Privacy Policy');
  }

  void _handleSupport() {
    _showComingSoonDialog('Support');
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(feature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'construction',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              '$feature is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'This feature is currently under development.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
