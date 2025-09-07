import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final String icon;
  final List<Widget> children;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

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
                  iconName: icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
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
              children: children.map((child) {
                final index = children.indexOf(child);
                final isLast = index == children.length - 1;

                return Column(
                  children: [
                    child,
                    if (!isLast)
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        indent: 16.w,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
