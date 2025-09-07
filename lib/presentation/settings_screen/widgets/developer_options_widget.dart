import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DeveloperOptionsWidget extends StatefulWidget {
  final bool isDebugMode;
  final bool isMockData;
  final String apiEndpoint;
  final ValueChanged<bool> onDebugModeChanged;
  final ValueChanged<bool> onMockDataChanged;
  final ValueChanged<String> onApiEndpointChanged;

  const DeveloperOptionsWidget({
    Key? key,
    required this.isDebugMode,
    required this.isMockData,
    required this.apiEndpoint,
    required this.onDebugModeChanged,
    required this.onMockDataChanged,
    required this.onApiEndpointChanged,
  }) : super(key: key);

  @override
  State<DeveloperOptionsWidget> createState() => _DeveloperOptionsWidgetState();
}

class _DeveloperOptionsWidgetState extends State<DeveloperOptionsWidget> {
  final TextEditingController _endpointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _endpointController.text = widget.apiEndpoint;
  }

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'developer_mode',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Developer Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'OPERATOR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: Theme.of(context).cardTheme.elevation,
            color: Theme.of(context).cardTheme.color,
            shape: Theme.of(context).cardTheme.shape,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'bug_report',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Debug Mode',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    widget.isDebugMode
                        ? 'Debug logging is enabled'
                        : 'Debug logging is disabled',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: widget.isDebugMode,
                    onChanged: widget.onDebugModeChanged,
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: 16.w,
                  color: Theme.of(context).dividerColor,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'data_object',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Mock Data',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    widget.isMockData
                        ? 'Using mock data for testing'
                        : 'Using live data from API',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: widget.isMockData,
                    onChanged: widget.onMockDataChanged,
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: 16.w,
                  color: Theme.of(context).dividerColor,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'api',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(
                    'API Endpoint',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    widget.apiEndpoint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'edit',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: _showApiEndpointDialog,
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: 16.w,
                  color: Theme.of(context).dividerColor,
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'clear_all',
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  title: Text(
                    'Clear Cache',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  subtitle: Text(
                    'Clear all cached data and preferences',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  onTap: _showClearCacheDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApiEndpointDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('API Endpoint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure the API endpoint for data retrieval:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _endpointController,
              decoration: InputDecoration(
                labelText: 'API Endpoint URL',
                hintText: 'https://api.example.com/v1',
                border: OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Presets:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            _buildPresetButton('Production', 'https://api.orbitflash.io/v1'),
            _buildPresetButton(
                'Staging', 'https://staging-api.orbitflash.io/v1'),
            _buildPresetButton(
                'Development', 'https://dev-api.orbitflash.io/v1'),
            _buildPresetButton('Local', 'http://localhost:3000/v1'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onApiEndpointChanged(_endpointController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API endpoint updated'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String name, String url) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _endpointController.text = url,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Clear Cache',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'This will clear all cached data, preferences, and temporary files. '
              'The app may need to reload data from the server.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _performCacheClear();
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _performCacheClear() {
    // Simulate cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
