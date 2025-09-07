import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TaskStatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const TaskStatusBadge({
    Key? key,
    required this.status,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppTheme.warningLight.withValues(alpha: 0.1);
        textColor = AppTheme.warningLight;
        displayText = 'Pending';
        break;
      case 'processing':
        backgroundColor = AppTheme.primaryLight.withValues(alpha: 0.1);
        textColor = AppTheme.primaryLight;
        displayText = 'Processing';
        break;
      case 'completed':
        backgroundColor = AppTheme.successLight.withValues(alpha: 0.1);
        textColor = AppTheme.successLight;
        displayText = 'Completed';
        break;
      case 'failed':
        backgroundColor = AppTheme.errorLight.withValues(alpha: 0.1);
        textColor = AppTheme.errorLight;
        displayText = 'Failed';
        break;
      default:
        backgroundColor = AppTheme.secondaryLight.withValues(alpha: 0.1);
        textColor = AppTheme.secondaryLight;
        displayText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize ?? 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
