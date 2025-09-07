import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricSettingsWidget extends StatelessWidget {
  final bool isBiometricEnabled;
  final ValueChanged<bool> onChanged;

  const BiometricSettingsWidget({
    Key? key,
    required this.isBiometricEnabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: 'fingerprint',
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(
        'Biometric Authentication',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        isBiometricEnabled
            ? 'Use biometric authentication to unlock'
            : 'Biometric authentication is disabled',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Switch(
        value: isBiometricEnabled,
        onChanged: (value) {
          // Show confirmation dialog for security-sensitive changes
          if (!value) {
            _showDisableBiometricDialog(context, value);
          } else {
            onChanged(value);
          }
        },
      ),
    );
  }

  void _showDisableBiometricDialog(BuildContext context, bool newValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Disable Biometric Authentication'),
        content: Text(
          'Are you sure you want to disable biometric authentication? '
          'You will need to use your wallet password to unlock the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onChanged(newValue);
            },
            child: Text(
              'Disable',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
