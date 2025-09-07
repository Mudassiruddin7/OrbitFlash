import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onThemeChanged;

  const ThemeSelectorWidget({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: 'palette',
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(
        'Theme',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        selectedTheme,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: () => _showThemeSelector(context),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Select Theme',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, 'Light', 'light_mode'),
            _buildThemeOption(context, 'Dark', 'dark_mode'),
            _buildThemeOption(context, 'Auto', 'brightness_auto'),
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

  Widget _buildThemeOption(BuildContext context, String theme, String icon) {
    final isSelected = selectedTheme == theme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        theme,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: () {
        onThemeChanged(theme);
        Navigator.pop(context);
      },
    );
  }
}
